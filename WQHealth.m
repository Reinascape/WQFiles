//
//  WQHealth.m
//  WQ Files
//

#import "WQHealth.h"
#import "WQAccess.h"
#import "WQAppsSupport.h"
#import "WQLaunchServices.h"
#import "WQLocalization.h"
#include <sys/stat.h>

@implementation WQHealthCheck
@end

static WQHealthCheck *wq_check(NSString *title, WQHealthState state, NSString *detail)
{
    WQHealthCheck *c = [WQHealthCheck new];
    c.title = WQLocalized(title);
    c.key = title;
    c.state = state;
    c.detail = detail ?: @"";
    return c;
}

static BOOL gBundlesReachable;
BOOL wq_app_bundles_reachable(void) { return gBundlesReachable; }

WQHealthState wq_health_worst(NSArray<WQHealthCheck *> *checks)
{
    WQHealthState worst = WQHealthOK;
    for (WQHealthCheck *c in checks) if (c.state > worst) worst = c.state;
    return worst;
}

WQHealthState wq_health_access_state(NSUInteger opened, NSUInteger sampled)
{
    if (!sampled) return WQHealthSkipped;
    if (!opened) return WQHealthFailed;
    // Some apps' folders refuse for their own reasons; most must open.
    return opened * 2 >= sampled ? WQHealthOK : WQHealthWarning;
}

WQHealthState wq_health_names_state(BOOL namesLoaded, BOOL knownName, NSUInteger labeled, NSUInteger sampled)
{
    if (!namesLoaded || !knownName) return WQHealthWarning;
    if (sampled && labeled * 2 < sampled) return WQHealthWarning;
    return WQHealthOK;
}

// Up to `count` folders spread over the list, not WQ Files' own.
static NSArray<NSString *> *wq_health_sample(NSArray<NSString *> *containers, NSString *home, NSUInteger count)
{
    NSMutableArray *others = [NSMutableArray new];
    for (NSString *c in containers)
        if (![[c stringByResolvingSymlinksInPath] isEqualToString:home]) [others addObject:c];
    if (others.count <= count) return others;
    NSMutableArray *picked = [NSMutableArray new];
    for (NSUInteger i = 0; i < count; i++) [picked addObject:others[i * others.count / count]];
    return picked;
}

// Diagnostics only (Log): what iOS's rendered icon cache holds. iOS 26+
// hands this app only the placeholder icon and app bundles don't open, so
// this cache is the remaining source of icons. On 27.0.1 it opens; its files
// sit in subfolders, so walk a few levels and log names, sizes and headers.
static void wq_health_icon_hex(NSString *path, unsigned long long size)
{
    NSData *head = wq_read_range(path, 0, 48, NULL);
    NSMutableString *hex = [NSMutableString new];
    const uint8_t *b = head.bytes;
    for (NSUInteger i = 0; i < head.length; i++) [hex appendFormat:@"%02x", b[i]];
    wq_log(@"icon cache: %@: %llu bytes, starts %@", path.lastPathComponent, size, hex.length ? hex : @"(unreadable)");
}

static void wq_health_icon_walk(NSString *dir, NSUInteger depth, NSUInteger *filesShown, NSUInteger *dirsShown)
{
    if (depth > 4 || *dirsShown >= 12) return;
    (*dirsShown)++;
    wq_grant(dir);
    NSString *error = nil;
    NSArray<NSString *> *names = [wq_list(dir, &error) sortedArrayUsingSelector:@selector(compare:)];
    if (!names) { wq_log(@"icon cache: %@: %@", dir, error ?: @"can't list"); return; }
    NSMutableDictionary<NSString *, NSNumber *> *extensions = [NSMutableDictionary new];
    for (NSString *n in names) {
        NSString *ext = n.pathExtension.length ? n.pathExtension : @"(none)";
        extensions[ext] = @(extensions[ext].unsignedIntegerValue + 1);
    }
    wq_log(@"icon cache: %@: %lu entries %@: %@", dir, (unsigned long)names.count,
           [extensions.description stringByReplacingOccurrencesOfString:@"\n" withString:@""],
           [[names subarrayWithRange:NSMakeRange(0, MIN(names.count, (NSUInteger)8))] componentsJoinedByString:@", "]);
    NSUInteger subdirs = 0, filesHere = 0;
    for (NSString *n in names) {
        NSString *path = [dir stringByAppendingPathComponent:n];
        struct stat st;
        if (!wq_stat(path, &st)) continue;
        if (S_ISDIR(st.st_mode)) {
            if (subdirs++ < 3) wq_health_icon_walk(path, depth + 1, filesShown, dirsShown);
        } else if (S_ISREG(st.st_mode) && *filesShown < 10 && filesHere < 4 && ![n hasPrefix:@".com.apple.mobile_container_manager"]) {
            wq_health_icon_hex(path, (unsigned long long)st.st_size);
            (*filesShown)++; filesHere++;
        }
    }
}

static void wq_health_probe_icon_cache(void)
{
    NSUInteger files = 0, dirs = 0;
    wq_health_icon_walk(@"/private/var/containers/Shared/SystemGroup/systemgroup.com.apple.lsd.iconscache/Library/Caches/com.apple.IconsCache",
                        0, &files, &dirs);
}

NSArray<WQHealthCheck *> *wq_health_run(void (^stage)(NSString *))
{
    NSMutableArray<WQHealthCheck *> *checks = [NSMutableArray new];
    NSOperatingSystemVersion os = NSProcessInfo.processInfo.operatingSystemVersion;
    NSString *osText = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)os.majorVersion, (long)os.minorVersion, (long)os.patchVersion];

    // 1. App Group: without it no token can be asked for.
    if (stage) stage(WQLocalized(@"Checking the App Group…"));
    NSString *group = wq_app_group();
    [checks addObject:wq_check(@"App Group", group ? WQHealthOK : WQHealthFailed,
        group ?: WQLocalized(@"Missing: the tool that signed WQ Files removed it. Re-install with AltStore, SideStore or Impactor.")) ];

    // 2. Other apps' folders.
    if (stage) stage(WQLocalized(@"Finding other apps' folders…"));
    NSString *home = [NSHomeDirectory() stringByResolvingSymlinksInPath];
    NSArray<NSString *> *containers = group ? wq_enumerate(@"/private/var/mobile/Containers/Data/Application", 0, nil, nil) : nil;
    NSArray<NSString *> *sample = wq_health_sample(containers ?: @[], home, 8);
    WQHealthCheck *folders;
    if (!group) folders = wq_check(@"Other apps' folders", WQHealthSkipped, WQLocalized(@"Needs the App Group."));
    else if (!containers && wq_full_scan_was_declined())
        folders = wq_check(@"Other apps' folders", WQHealthSkipped, WQLocalized(@"The scan for them was declined; Apps and the Cache Cleaner stay empty until it runs."));
    else if (!containers)
        folders = wq_check(@"Other apps' folders", WQHealthFailed, WQLocalized(@"They can't be found on this device (see Log for the reason)."));
    else if (!sample.count)
        folders = wq_check(@"Other apps' folders", WQHealthFailed, WQLocalizedFormat(@"Only WQ Files' own folder was found (%lu in total).", (unsigned long)containers.count));
    else
        folders = wq_check(@"Other apps' folders", WQHealthOK, WQLocalizedFormat(@"%lu found.", (unsigned long)containers.count));
    [checks addObject:folders];

    // 3. Sandbox access: tokens that really open those folders.
    if (stage) stage(WQLocalized(@"Checking access…"));
    NSUInteger opened = 0, labeled = 0;
    NSMutableArray *refused = [NSMutableArray new];
    for (NSString *c in sample) {
        NSString *error = nil;
        if (wq_grant(c) && wq_list(c, &error)) opened++;
        else [refused addObject:[NSString stringWithFormat:@"%@ (%@)", c.lastPathComponent, error ?: @"no token"]];
        NSString *label = wq_container_label(c);
        if (label && WQAppsSupportBundleIDValid(label)) labeled++;
    }
    WQHealthState access = wq_health_access_state(opened, sample.count);
    if (refused.count) wq_log(@"health: %lu of %lu sampled folders refused: %@", (unsigned long)refused.count,
                              (unsigned long)sample.count, [refused componentsJoinedByString:@", "]);
    [checks addObject:wq_check(@"Sandbox access", access,
        access == WQHealthSkipped ? WQLocalized(@"Nothing to check.")
        : access == WQHealthFailed ? WQLocalizedFormat(@"None of %lu sampled app folders could be opened: the sandbox escape doesn't work on iOS %@.", (unsigned long)sample.count, osText)
        : WQLocalizedFormat(@"%lu of %lu sampled app folders open.", (unsigned long)opened, (unsigned long)sample.count))];

    // 4. App database: names and container labels (layout offsets).
    if (stage) stage(WQLocalized(@"Reading app names…"));
    if (group && access != WQHealthFailed && !wq_display_names_loaded()) wq_load_display_names();
    BOOL namesLoaded = wq_display_names_loaded();
    BOOL knownName = namesLoaded && wq_display_name(@"com.apple.mobilesafari").length > 0;
    WQHealthState names = access == WQHealthFailed || !group ? WQHealthSkipped
                        : wq_health_names_state(namesLoaded, knownName, labeled, sample.count);
    [checks addObject:wq_check(@"App names", names,
        names == WQHealthSkipped ? WQLocalized(@"Needs sandbox access.")
        : names == WQHealthOK ? WQLocalizedFormat(@"%lu of %lu sampled folders identified.", (unsigned long)labeled, (unsigned long)sample.count)
        : WQLocalizedFormat(@"The app database can't be read properly on iOS %@ (%lu of %lu sampled folders identified). Apps show folder IDs instead of names; backups and restores need the right app, so check before restoring.", osText, (unsigned long)labeled, (unsigned long)sample.count))];

    // App bundles open on some iOS versions only (not on 26 or 27.0.1):
    // App Bundles and Open App Bundle are shown when one does.
    BOOL bundles = NO;
    if (access == WQHealthOK) {
        NSArray<NSString *> *all = wq_ls_bundle_containers();
        for (NSUInteger i = 0; i < all.count && i < 3 && !bundles; i++) {
            NSString *b = all[i * all.count / 3];
            bundles = wq_grant(b) && wq_list(b, NULL) != nil;
        }
        wq_log(@"health: app bundle folders %@", bundles ? @"open" : @"don't open (App Bundles hidden)");
    }
    gBundlesReachable = bundles;
    static dispatch_once_t iconProbe;
    if (access == WQHealthOK && !bundles) dispatch_once(&iconProbe, ^{ wq_health_probe_icon_cache(); });

    // 5. iOS version.
    BOOL tested = os.majorVersion == 26 || os.majorVersion == 27;
    [checks addObject:wq_check(@"iOS version", tested ? WQHealthOK : WQHealthWarning,
        tested ? osText : WQLocalizedFormat(@"iOS %@ hasn't been tested with this version of WQ Files.", osText))];

    NSMutableArray *summary = [NSMutableArray new];
    for (WQHealthCheck *c in checks) [summary addObject:[NSString stringWithFormat:@"%@=%@", c.key,
        @[@"ok", @"skipped", @"warning", @"FAILED"][(NSUInteger)c.state]]];
    wq_log(@"health: iOS %@: %@", osText, [summary componentsJoinedByString:@", "]);
    return checks;
}
