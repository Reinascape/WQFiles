// Shared container scan lifecycle: refresh invalidation (CR-08), the full-scan
// coordinator (CR-10) and identity-bound label caches (CR-12). No real scan
// runs: the shared-scan worker is replaced by a blocking test runner.
#define WQ_ACCESS_TESTING 1
#import "../WQAccess.m"
#include <stdlib.h>
SecTaskRef SecTaskCreateFromSelf(CFAllocatorRef allocator) { (void)allocator; return NULL; }
CFTypeRef SecTaskCopyValueForEntitlement(SecTaskRef task, CFStringRef entitlement, CFErrorRef *error)
{ (void)task; (void)entitlement; (void)error; return NULL; }

static void check(BOOL ok, NSString *name)
{
    if (!ok) { fprintf(stderr, "FAIL: %s\n", name.UTF8String); exit(1); }
    printf("PASS: %s\n", name.UTF8String);
}

static BOOL waitFor(dispatch_semaphore_t sem, double seconds)
{
    return dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC))) == 0;
}

static NSString *kRoot;
static fsid_t kFsid;

static NSArray<NSString *> *children(void)
{
    return wq_shared_children(kRoot, kFsid, nil, nil);
}

// The worker started before a refresh blocks; the refresh happens; a caller
// after the refresh must get a new scan, never the pre-refresh result.
static void testInvalidationDuringBlockedWorker(void)
{
    wq_enumerate_invalidate();
    __block _Atomic int calls = 0;
    dispatch_semaphore_t entered = dispatch_semaphore_create(0);
    dispatch_semaphore_t release = dispatch_semaphore_create(0);
    wq_test_shared_scan_runner = ^NSDictionary *(BOOL __unused inodeOnly) {
        int n = atomic_fetch_add(&calls, 1) + 1;
        if (n == 1) {
            dispatch_semaphore_signal(entered);
            dispatch_semaphore_wait(release, DISPATCH_TIME_FOREVER);
            return @{ kRoot: @[@"old"] };
        }
        return @{ kRoot: @[[NSString stringWithFormat:@"new%d", n]] };
    };
    __block NSArray *first = nil, *second = nil;
    dispatch_semaphore_t firstDone = dispatch_semaphore_create(0), secondDone = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{ first = children(); dispatch_semaphore_signal(firstDone); });
    check(waitFor(entered, 5), @"first worker started");
    wq_enumerate_invalidate();
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{ second = children(); dispatch_semaphore_signal(secondDone); });
    usleep(400000);
    check(atomic_load(&calls) == 1, @"post-refresh worker waits for the detached one instead of overlapping");
    dispatch_semaphore_signal(release);
    check(waitFor(firstDone, 5) && waitFor(secondDone, 5), @"both callers finish");
    check([first isEqualToArray:@[@"old"]], @"pre-refresh caller keeps its own result");
    check([second isEqualToArray:@[@"new2"]], @"post-refresh caller gets a fresh generation");
    check([children() isEqualToArray:@[@"new2"]] && atomic_load(&calls) == 2, @"slot caches the fresh result, not the stale one");
    wq_test_shared_scan_runner = nil;
}

// The detached worker completes before anyone asks again: its result must not
// be published as the post-refresh cache.
static void testStaleWorkerDoesNotRepublish(void)
{
    wq_enumerate_invalidate();
    __block _Atomic int calls = 0;
    dispatch_semaphore_t entered = dispatch_semaphore_create(0);
    dispatch_semaphore_t release = dispatch_semaphore_create(0);
    wq_test_shared_scan_runner = ^NSDictionary *(BOOL __unused inodeOnly) {
        int n = atomic_fetch_add(&calls, 1) + 1;
        if (n == 1) {
            dispatch_semaphore_signal(entered);
            dispatch_semaphore_wait(release, DISPATCH_TIME_FOREVER);
            return @{ kRoot: @[@"stale"] };
        }
        return @{ kRoot: @[@"fresh"] };
    };
    dispatch_semaphore_t done = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{ (void)children(); dispatch_semaphore_signal(done); });
    check(waitFor(entered, 5), @"stale worker started");
    wq_enumerate_invalidate();
    dispatch_semaphore_signal(release);
    check(waitFor(done, 5), @"stale worker finished");
    usleep(100000);
    check([children() isEqualToArray:@[@"fresh"]] && atomic_load(&calls) == 2, @"stale worker result not reused after refresh");
    // Without an invalidation the result is reused.
    check([children() isEqualToArray:@[@"fresh"]] && atomic_load(&calls) == 2, @"current result reused within the TTL");
    wq_test_shared_scan_runner = nil;
}

// Only one full scan holds the stop token / window / background task at a time.
static void testFullScanCoordinator(void)
{
    check(wq_full_scan_acquire(@"first", nil), @"first full scan acquires the gate");
    WQScanCancellation *stop = [WQScanCancellation new];
    @synchronized (NSNull.null) { gFullScanStop = stop; }
    __block _Atomic BOOL secondIn = NO;
    dispatch_semaphore_t secondDone = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        BOOL ok = wq_full_scan_acquire(@"second", nil);
        atomic_store(&secondIn, ok);
        dispatch_semaphore_signal(secondDone);
    });
    usleep(400000);
    check(!atomic_load(&secondIn), @"second full scan waits while the first runs");
    WQScanCancellation *caller = [WQScanCancellation new];
    __block BOOL thirdResult = YES;
    dispatch_semaphore_t thirdDone = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        thirdResult = wq_full_scan_acquire(@"third", caller);
        dispatch_semaphore_signal(thirdDone);
    });
    [caller cancel];
    check(waitFor(thirdDone, 3) && !thirdResult, @"a cancelled caller stops waiting for the gate");
    wq_full_scan_stop();
    check(stop.isCancelled, @"Stop addresses the running scan");
    wq_full_scan_end(stop);
    check(waitFor(secondDone, 3) && atomic_load(&secondIn), @"next full scan starts only after the first ended");
    @synchronized (NSNull.null) { check(gFullScanStop == nil, @"ended scan's token cleared"); }
    wq_full_scan_release();
}

int main(void)
{
    @autoreleasepool {
        kRoot = wq_shared_scan_roots()[0];
        memset(&kFsid, 0, sizeof(kFsid));
        testInvalidationDuringBlockedWorker();
        testStaleWorkerDoesNotRepublish();
        testFullScanCoordinator();
        printf("All WQAccess scan lifecycle tests passed.\n");
    }
    return 0;
}
