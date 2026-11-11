# WQ Files 简体中文本地化对照（审核版）

> 状态：**已审核，随简体中文本地化一起提交**
> 账号：`iosrxwy`
> 基线：`kolbicz/WQFiles` `main` @ `f149ba8`（v0.8-b36）
> 工作分支：`zh-hans-localization`
> 对照范围：763 条，约 698 个唯一源字符串；覆盖 14 个用户可见页面/流程、按钮、状态、主要错误和内置系统服务名。

## 先说明一件事

这个仓库目前没有语音播放、TTS 或音频资源功能，因此我把“中文语音包”按“简体中文语言包 / 汉化”来处理：系统语言为简体中文时显示中文，其他语言继续显示英文。

如果你要的其实是可播放的中文语音音频包（例如某个语音播报功能），那和当前项目不是同一件事，需要你指出需要配音的具体功能。下面的对照表针对的是 **App 界面、操作提示、错误信息和内置系统服务名称**。

## 实现与提交

1. 增加 `zh-Hans.lproj/Localizable.strings`（中文界面文本）。App 显示名保持 `WQ Files`，不需要 `InfoPlist.strings`。
2. 在 `Info.plist` 声明 `en`、`zh-Hans` 本地化，并让 `build.sh` 把 `.lproj` 资源打进 App。
3. 把界面、操作按钮、提示和可显示错误改为通过统一本地化函数取文本；路径、Bundle ID、`osanalytics`、Plist 键名等保持原样。路径中的 `tmp` 不改，界面标签写“临时文件”。
4. 保留所有格式占位符（`%@`、`%lu`、`%lld` 等），保证中英文共用同一套逻辑。
5. 运行 `./tests/run_all_tests.sh`，通过后提交到 `iosrxwy/WQFiles` 的分支并创建 PR。

## 需要你重点确认的译法

| 项目 | 建议 | 备选 | 说明 |
|---|---|---|---|
| App 名称 | `WQ Files` | 不改 | 保持现有品牌名，不翻译 |
| App Data | `应用数据` | `App 数据` | 按你的要求统一改为“应用数据” |
| App Groups | `应用组` | `App Groups` | 按你的要求统一使用“应用组” |
| Internal Daemons | `内部守护进程` | `内部 Daemon` | 面向用户的解释性翻译 |
| Restore | `还原备份` / `还原文件` | 不采用两字词 | 先看源码语义：App 备份用“还原备份”，单文件用“还原文件”；按钮和标题统一四字 |
| Clear | `清除` | `清理` | 清除数据用`清除`，清理缓存用`清理` |
| Backups | `备份` | `备份文件夹` | 作为入口和文件夹名称时统一为`备份` |
| tmp | `临时文件` | `tmp` | `tmp` 是 App 的临时目录，不等同于全部缓存；路径仍写 `tmp`，界面标签写“临时文件” |
| token | `令牌` | `Token` | 技术错误里保留括号说明 |
| inode | `inode` | `索引节点` | 保留技术原名，便于排查 |
| Plist | `Plist` | `属性列表` | 标题用`Plist`，说明性正文可写`属性列表` |
| AirDrop | `隔空投送` | `AirDrop` | 采用 Apple 简体中文名称 |
| Share | `分享` | `共享` | 采用 iOS 分享面板用语 |

统一使用中文标点（`，。：；！？（）`），英文专有名词、路径和占位符两侧保留英文语境需要的空格。

---

## 这版不是只改“彩蛋页面”

用户可见的主要页面和流程都在范围内，不只改关于页或几个说明页：

| 页面/流程 | 源码入口 | 中文化内容 |
|---|---|---|
| 根目录 | `WQRootViewController`（`main.m`） | 容器入口、工具入口、页面说明、署名、前往路径 |
| 系统组 | `WQSystemGroupsViewController` | 标题、列表、无法枚举说明、添加/打开弹窗、未找到 |
| 文件浏览器 | `WQDirViewController` | 搜索、菜单、多选文件/备份、移动、压缩/解压、空状态/错误、分享、删除、重命名、导入、单文件还原 |
| 文本/图片查看 | `WQFileViewController` | 打开方式、编辑/保存/放弃、加载错误、符号链接提示 |
| 媒体播放器 | `wq_open_media` / `AVPlayerViewController` | 媒体打开、临时副本、播放失败 |
| Plist 编辑器 | `WQPlistEditorViewController` | 类型名、新增/删除/重命名/排序、保存/放弃、校验错误 |
| 十六进制查看器/编辑器 | `WQHexViewController` | 查看/编辑、保存/放弃、偏移、查找、覆盖、错误 |
| SQLite 查看器 | `WQSQLiteViewController` | 表/视图、行、单行详情、SQL 查询、CSV 导出、只读说明 |
| Apps 管理 | `WQAppsViewController` | 列表、搜索、备份、清除、App 备份还原、还原/回滚错误 |
| 缓存清理 | `WQCacheCleanerViewController` | 扫描、选择、清理、崩溃日志、状态、清理范围与错误 |
| 日志 | `WQLogViewController` | 标题、版本/设备头、分享日志 |
| 关于/署名 | `WQRootViewController authorFooter` | 品牌、作者、GitHub/X 署名、沙盒技术说明 |
| 分享/导出 | `WQSharing` | 准备压缩、取消、ZIP 创建失败、分享冲突 |
| 启动/全局提示 | `WQRootViewController`、`WQApps` | 中断还原、No App Group、签名问题、备份/还原安全错误 |
| 全盘扫描 | `WQScanWindowController`、`main.m` | 扫描确认、进度、剩余时间、隐藏/停止、扫描说明 |

源码层面需要接入中文的文件：

| 源码文件 | 需要中文化的内容 |
|---|---|
| `main.m` | 根目录、文件浏览器、文本/图片查看、Plist/十六进制入口、系统组、日志、关于页、单文件还原 |
| `WQApps.m` | Apps 列表、搜索、备份、清除、App 备份还原、回滚与启动还原提示 |
| `WQCache.m` | 缓存清理页、扫描状态、选择菜单、清理确认、崩溃日志 |
| `WQPlistEditor.m` | Plist 编辑器的类型、菜单、编辑/新增/重命名、保存与校验 |
| `WQHexViewer.m` | 十六进制查看/编辑、偏移、查找、覆盖、保存 |
| `WQSQLiteViewer.m` | SQLite 表/视图、行、查询、CSV 导出和只读说明 |
| `WQArchive.m` | ZIP 压缩/解压、安全校验和压缩包错误 |
| `WQSharing.m` | ZIP 准备、取消、分享冲突和失败提示 |
| `WQUI.m` | 通用提示按钮、大小显示等共享 UI |
| `WQAccess.m` | 会显示到 UI 的文件操作、复制、权限和保存错误 |
| `WQAppsSupport.h` | 备份清单校验、还原策略错误 |
| `WQPlistEditorSupport.h` | 属性列表解析/类型错误 |
| `WQLaunchServices.m` | 内置系统 App/服务名称回退表 |

另有两类不需要手写中文：

- iOS 自己的分享面板、文件选择器、系统操作表和菜单由系统语言本地化。
- 日志里的技术行、绝对路径、Bundle ID、Plist 键名、SF Symbols 不翻译，用于排查问题。

## Restore 到底还原什么

源码里的 `Restore` 不是同一个动作，主要分三种：

| 场景 | 源码位置 | 实际行为 | 四字译法 |
|---|---|---|---|
| App 备份还原 | `WQApps.m` 的 `restore:from:title:message:`，约 1103–1219 行 | 用所选备份替换 App 当前的 `Documents` 和 `Library`；`tmp` 不动。当前数据先做安全备份，失败会回滚。 | `还原备份` |
| 单文件备份还原 | `main.m` 的 `restoreBackup:to:`，约 1285–1298 行 | 把某个文件备份写回原路径；原路径已有文件时先备份。 | `还原文件` |
| 启动时处理中断的 App 备份还原 | `wq_recover_interrupted_restore`，约 1044–1101 行 | 上次 App 备份还原没走完，启动时用安全备份把应用数据弄回一致状态。 | `中断还原` |

对应的四字结果/按钮：

| 原文 | 建议中文 | 说明 |
|---|---|---|
| `Restore`（App 备份） | `还原备份` | 四个汉字 |
| `Restore`（单文件） | `还原文件` | 四个汉字 |
| `Restore to Original Location` | `还原原位` | 四个汉字 |
| `Restore Backup (%@)` | `还原备份（%@）` | 四个汉字 + 原名参数 |
| `Restore a Backup… (%lu)` | `还原备份…（%lu）` | 四个汉字 + 数量 |
| `Restore which backup?` | `选择备份` | 四个汉字 |
| `Restore %@?` | `还原“%@”备份？` | 四个汉字 + App 名 |
| `Restored` | `还原成功` | 四个汉字 |
| `Not restored` | `未能还原` | 四个汉字 |
| `Restore failed` | `还原失败` | 四个汉字 |
| `Restore recovery` | `中断还原` | 四个汉字 |

说明性长句仍会写“还原日志”“自动还原”等，但按钮、标题和结果提示优先用上面的四字译法。

### `tmp` 和缓存的关系

- `Library/Caches` 是严格意义上的缓存目录，界面叫“缓存”。
- `tmp` 是 App 的临时文件目录，不等同于全部缓存，但缓存清理功能会同时测量并删除 `Library/Caches` 和 `tmp`。
- 因此界面文案统一写“临时文件”；真正显示文件系统路径时仍保留 `tmp`，否则用户会找不到目录。
- 例如：`Delete Library/Caches and tmp` 译为“删除缓存和临时文件”；`Show tmp in File Browser` 译为“在文件浏览器中显示临时文件”；但路径 `/.../tmp` 不改。

## 1. 根界面、文件夹与通用操作

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `WQ Files` | `WQ Files` | App 标题（不改） |
| `Containers` | `容器` | 根界面分组 |
| `Tools` | `工具` | 根界面分组 |
| `App Data` | `应用数据` | 根界面入口 |
| `App Groups` | `应用组` | 根界面入口 |
| `Extension Data` | `扩展数据` | 根界面入口 |
| `Internal Daemons` | `内部守护进程` | 根界面入口 |
| `System Data` | `系统数据` | 根界面入口 |
| `System Groups` | `系统组` | 根界面入口 |
| `Apps` | `App` | 工具入口 |
| `Cache Cleaner` | `缓存清理` | 工具入口 |
| `Go to Path…` | `前往路径…` | 工具入口 |
| `App Backups` | `App 备份` | 工具入口 |
| `Backups` | `备份` | 工具入口 |
| `Log` | `日志` | 工具入口 |
| `Home` | `首页` | 无障碍标签 |
| `Loading…` | `正在载入…` | 加载状态 |
| `Open As` | `打开方式` | 文件菜单 |
| `Plist Editor` | `Plist 编辑器` | 打开方式 |
| `Hex Viewer` | `十六进制查看器` | 打开方式 |
| `Text / Image` | `文本 / 图像` | 打开方式 |
| `Share` | `分享` | 菜单/按钮 |
| `Share as ZIP (AirDrop…)` | `以 ZIP 分享（隔空投送…）` | 文件夹菜单 |
| `Restore to Original Location` | `还原原位` | 备份菜单 |
| `Copy Identifier` | `复制标识符` | 文件菜单 |
| `Copy Path` | `复制路径` | 文件夹菜单 |
| `New Folder` | `新建文件夹` | 文件夹菜单 |
| `Import File` | `导入文件` | 文件夹菜单 |
| `Select` | `选择` | 多选入口 |
| `Select All` | `全选` | 多选 |
| `Done` | `完成` | 多选完成 |
| `Done Reordering` | `完成排序` | Plist 排序 |
| `Reorder Items` | `重新排列项目` | Plist 排序 |
| `Save` | `保存` | 编辑器 |
| `Edit` | `编辑` | 文本查看器 |
| `Delete` | `删除` | 操作按钮 |
| `Rename` | `重命名` | 操作按钮 |
| `Create` | `创建` | 新建文件夹 |
| `Replace` | `替换` | 导入冲突 |
| `Open` | `打开` | 通用按钮 |
| `Go` | `前往` | 十六进制偏移 |
| `Find` | `查找` | 十六进制搜索 |
| `Set` | `设置` | 十六进制覆盖 |
| `Add` | `添加` | Plist 新项目 |
| `Stop` | `停止` | 缓存清理 |
| `Clean` | `清理` | 缓存清理 |
| `Cancel` | `取消` | 通用按钮 |
| `OK` | `好` | 通用提示按钮 |
| `Not found` | `未找到` | 路径/系统组 |
| `Path copied` | `路径已复制` | 复制路径提示 |
| `Search this folder` | `搜索此文件夹` | 文件搜索 |
| `Search names and bundle IDs` | `搜索名称和 Bundle ID` | 容器列表搜索 |
| `Search apps` | `搜索 App` | App 搜索 |
| `Scanning…` | `正在扫描…` | 状态 |
| `Reading app names…` | `正在读取 App 名称…` | App 扫描状态 |
| `Reading containers… %lu of %lu` | `正在读取容器… %lu / %lu` | 容器扫描状态 |
| `Scanning inodes…` | `正在扫描 inode…` | 容器扫描状态 |
| `Scanning inodes… %lld%% · %lu found%@` | `正在扫描 inode… %lld%% · 已找到 %lu 个%@` | 容器扫描状态 |
| ` · about %.0f min left` | ` · 约剩 %.0f 分钟` | 扫描剩余时间 |
| ` · less than 2 min left` | ` · 剩余不到 2 分钟` | 扫描剩余时间 |
| `(no label)` | `（无标签）` | 未识别的容器 |
| `NO TOKEN` | `无令牌` | 沙盒访问失败 |
| `File Backups` | `文件备份` | 备份入口 |
| `Access unavailable · %@` | `访问不可用 · %@` | App 列表副标题 |
| `size unavailable · %@%@` | `大小不可用 · %@%@` | App 列表副标题 |
| ` · backed up` | ` · 已备份` | App 列表副标题 |
| `size unavailable` | `大小不可用` | App 详情 |
| `unknown` | `未知` | 通用占位 |
| `unknown error` | `未知错误` | 通用错误 |
| `Unknown error` | `未知错误` | 通用错误 |
| `see Log` | `见日志` | 错误提示 |

## 2. 文件浏览器、备份与还原

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `The file changed while it was being read. Open it again.` | `读取期间文件已更改，请重新打开。` | 文件读取失败 |
| `Could not establish a stable file version. Open it again.` | `无法确认稳定的文件版本，请重新打开。` | 文件读取失败 |
| `Cannot read this file.\n\n%@` | `无法读取此文件。\n\n%@` | 文件查看器 |
| `%@ · read only` | `%@ · 只读` | 文件状态 |
| `Cannot read %@` | `无法读取 %@` | 文件操作错误 |
| `Cannot access %@` | `无法访问 %@` | 文件操作错误 |
| `Invalid file path` | `文件路径无效` | 文件操作错误 |
| `Invalid folder path` | `文件夹路径无效` | 文件夹操作错误 |
| `Invalid copy path` | `复制路径无效` | 复制错误 |
| `Invalid name` | `名称无效` | 重命名错误 |
| `Only empty folders can be deleted` | `只能删除空文件夹` | 删除错误 |
| `Only a complete backup unit can be deleted here.` | `此处只能删除完整的备份单元。` | 备份删除 |
| `Could not remove everything inside the backup.` | `无法移除备份中的所有内容。` | 备份删除 |
| `Backup storage cannot be modified through the file browser.` | `不能通过文件浏览器修改备份存储。` | 安全限制 |
| `Backup storage cannot be overwritten or deleted through the file browser.` | `不能通过文件浏览器覆盖或删除备份存储。` | 安全限制 |
| `Backup storage cannot be renamed through the file browser.` | `不能通过文件浏览器重命名备份存储。` | 安全限制 |
| `An item with that name already exists` | `已存在同名项目` | 重命名错误 |
| `Source and destination are the same file` | `源文件和目标文件相同` | 复制错误 |
| `The source changed while it was being copied` | `复制期间源文件已更改` | 复制错误 |
| `The source changed while it was copied` | `复制期间源文件已更改` | 复制错误 |
| `Destination is not a regular file` | `目标不是普通文件` | 复制错误 |
| `Cannot inspect the copy source` | `无法检查复制源` | 复制错误 |
| `Cannot read the source folder` | `无法读取源文件夹` | 文件夹复制错误 |
| `A copy root changed during copying` | `复制期间复制根目录已更改` | 文件夹复制错误 |
| `Cannot safely open distinct source and destination folders` | `无法安全地打开不同的源文件夹和目标文件夹` | 文件夹复制错误 |
| `Source and destination trees overlap or have invalid paths` | `源目录树和目标目录树重叠，或路径无效` | 文件夹复制错误 |
| `The file changed after it was opened. Your edits were not written; reopen it and compare the changes.` | `文件在打开后已更改。你的编辑未写入，请重新打开并比较更改。` | 保存冲突 |
| `The target path was replaced during writing` | `写入期间目标路径已被替换` | 保存冲突 |
| `Saved contents could not be verified; possible concurrent modification` | `无法验证已保存的内容；可能存在并发修改` | 保存冲突 |
| `Write failed` | `写入失败` | 保存错误 |
| `Backup copy failed.` | `备份副本失败。` | 备份错误 |
| `Backup of the current file failed, nothing was written: %@` | `当前文件的备份失败，未写入任何内容：%@` | 保存错误 |
| `The path is invalid or belongs to backup storage.` | `路径无效，或属于备份存储。` | 路径校验 |
| `\n… (only the beginning is shown)\n` | `\n…（仅显示开头部分）\n` | 文件预览截断 |
| `Only regular files can be viewed.` | `只能查看普通文件。` | 文件查看限制 |
| `Only regular files can be shared.` | `只能分享普通文件。` | 分享限制 |
| `Symbolic link` | `符号链接` | 文件类型 |
| `WQ Files does not follow symbolic links for viewing, sharing or editing.` | `WQ Files 在查看、分享或编辑时不会跟随符号链接。` | 符号链接提示 |
| `WQ Files does not follow symbolic links for viewing, sharing or editing. Use Copy Path to open the target explicitly.` | `WQ Files 在查看、分享或编辑时不会跟随符号链接。请使用“复制路径”显式打开目标。` | 符号链接提示 |
| `Symbolic links are not followed for viewing, sharing or editing.` | `查看、分享或编辑时不会跟随符号链接。` | 符号链接提示 |
| `This permanently removes %lu complete backup%@ and everything inside them. It cannot be undone.` | `这会永久删除 %lu 个完整备份%@及其中的所有内容，且无法撤销。` | 删除备份确认 |
| `Delete backups?` | `删除备份？` | 删除备份确认 |
| `Delete backup?` | `删除备份？` | 删除单个备份确认 |
| `Delete \"%@\"?` | `删除“%@”？` | 删除文件确认 |
| `%@\n\nThis removes every backup for this app. It cannot be undone.` | `%@\n\n这会删除此 App 的所有备份，且无法撤销。` | 删除备份确认 |
| `%@\n\nThis removes the selected backup. It cannot be undone.` | `%@\n\n这会删除所选备份，且无法撤销。` | 删除备份确认 |
| `%@\n\nRemoves the symbolic link only; its target is not changed.` | `%@\n\n仅移除符号链接，不会更改其目标。` | 删除符号链接 |
| `%@\n\nOnly empty folders can be deleted.` | `%@\n\n只能删除空文件夹。` | 删除文件夹 |
| `%@\n\nA copy is kept in Backups.` | `%@\n\n“备份”中会保留一份副本。` | 删除普通文件 |
| `%@\n\nThis special file is removed; no backup is kept.` | `%@\n\n将移除此特殊文件，不会保留备份。` | 删除特殊文件 |
| `Write this backup back to\n%@?\n\nIf a file is there now, it is backed up first.` | `要将此备份写回\n%@ 吗？\n\n如果该位置现在有文件，会先备份。` | 还原单个文件 |
| `Restore failed` | `还原失败` | 还原结果 |
| `Import failed` | `导入失败` | 导入结果 |
| `Could not remove a backup.` | `无法移除备份。` | 删除备份失败 |
| `Could not remove everything inside the backup.` | `无法移除备份中的所有内容。` | 删除备份失败 |
| `This folder cannot be listed on this iOS version. Known names that exist are shown; tap + to try another name.` | `此 iOS 版本无法列出此文件夹。会显示已知且存在的名称；点按 + 可尝试其他名称。` | 系统组说明 |
| `Open System Group` | `打开系统组` | 系统组输入框 |
| `A folder or file path` | `文件夹或文件路径` | 前往路径提示 |
| `Cannot create folder` | `无法创建文件夹` | 新建文件夹错误 |
| `Cannot rename` | `无法重命名` | 重命名错误 |
| `Cannot delete` | `无法删除` | 删除错误 |
| `Cannot delete backup` | `无法删除备份` | 删除备份错误 |
| `Cannot delete backups` | `无法删除备份` | 批量删除备份错误 |
| `Cannot list this folder. Container enumeration failed; see Log.` | `无法列出此文件夹。容器枚举失败，请查看日志。` | 文件夹加载失败 |
| `Cannot open this folder` | `无法打开此文件夹` | 文件夹加载失败 |
| `Replace existing file?` | `替换现有文件？` | 导入冲突 |
| `%@ already exists. It is backed up before being replaced.` | `%@ 已存在。替换前会先备份。` | 导入冲突 |

| `This method only opens containers. Use App Data, App Groups, Extension Data, Internal Daemons or System Groups for the folders inside /private/var.` | `此方式只能打开容器。请使用“应用数据”、“应用组”、“扩展数据”、“内部守护进程”或“系统组”访问 /private/var 内的文件夹。` | 非容器目录错误 |
| `symlink · ` | `符号链接 · ` | 文件列表副标题 |
| `Restore` | `还原文件` | 单文件备份还原按钮 |

## 3. Plist 编辑器与属性列表

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `Open as XML Text` | `以 XML 文本打开` | Plist 编辑器菜单 |
| `Open in Hex Viewer` | `在十六进制查看器中打开` | Plist 编辑器菜单 |
| `String` | `字符串` | Plist 类型 |
| `Number` | `数字` | Plist 类型 |
| `Real` | `实数` | Plist 类型 |
| `Boolean` | `布尔值` | Plist 类型 |
| `Date` | `日期` | Plist 类型 |
| `Data` | `数据` | Plist 类型 |
| `Dictionary` | `字典` | Plist 类型 |
| `Array` | `数组` | Plist 类型 |
| `Reference` | `引用` | Plist 类型 |
| `Whole number` | `整数` | 数字输入 |
| `YES` | `是` | 布尔值 |
| `NO` | `否` | 布尔值 |
| `(empty)` | `（空）` | 属性列表摘要 |
| ` … (%lu chars)` | ` …（%lu 个字符）` | 字符串摘要 |
| `keyed-archive reference` | `键控归档引用` | 类型说明 |
| `%lu bytes · %@` | `%lu 字节 · %@` | Plist 摘要 |
| `%lu keys` | `%lu 个键` | 字典摘要 |
| `%lu items` | `%lu 个项目` | 数组摘要 |
| `%@ · %@` | `%@ · %@` | Plist 摘要 |
| `Not a property list: %@` | `不是属性列表：%@` | 解析失败 |
| `Cannot read this file: %@` | `无法读取此文件：%@` | 解析失败 |
| `Your edits to this property list have not been saved.` | `你对属性列表的更改尚未保存。` | 放弃更改 |
| `Read-only format` | `只读格式` | 保存限制 |
| `This property list uses an OpenStep/unknown format that cannot be saved by the editor. Use Open as XML Text and choose a supported format explicitly.` | `此属性列表使用 OpenStep/未知格式，编辑器无法保存。请使用“以 XML 文本打开”，并明确选择受支持的格式。` | 保存限制 |
| `Cannot save safely` | `无法安全保存` | 保存失败 |
| `The current file version is unavailable. Reopen the file before saving again.` | `当前文件版本不可用，请重新打开文件后再保存。` | 保存失败 |
| `%@ is overwritten in place (%@ format). The current version is backed up first.` | `将原地覆盖 %@（%@ 格式）。当前版本会先备份。` | 保存确认 |
| `The edited property list contains an unsupported value.` | `编辑后的属性列表包含不支持的值。` | 保存校验 |
| `The edited property list is not valid.` | `编辑后的属性列表无效。` | 保存校验 |
| `The serialized property list is too large (maximum %lu MiB).` | `序列化后的属性列表过大（最大 %lu MiB）。` | 保存校验 |
| `The serialized property list could not be validated.` | `无法验证序列化后的属性列表。` | 保存校验 |
| `read only` | `只读` | 文件状态 |
| `read only · writing is not supported` | `只读 · 不支持写入` | 文件状态 |
| `%@ property list · %@` | `%@ 属性列表 · %@` | 文件状态 |
| `%@ property list. Tap a value to edit it, swipe to delete or rename, + to add.` | `%@ 属性列表。点按值可编辑，轻扫可删除或重命名，点按 + 可添加。` | Plist 使用说明 |
| `Item %ld` | `项目 %ld` | Plist 行标题 |
| `Reference value` | `引用值` | Plist 编辑器 |
| `Keyed-archive references are read-only in this editor. Edit the archived data through its owning key instead.` | `键控归档引用在此编辑器中为只读。请改为通过其所属键编辑归档数据。` | 引用编辑限制 |
| `Too large to edit here` | `过大，无法在此编辑` | 值过大 |
| `Data over 4 KB can't be edited in this editor.` | `超过 4 KB 的数据无法在此编辑器中编辑。` | 值过大 |
| `Strings over 64 KB can't be edited in this editor.` | `超过 64 KB 的字符串无法在此编辑器中编辑。` | 值过大 |
| `ISO 8601, e.g. 2026-11-09T15:00:00Z` | `ISO 8601，例如 2026-11-09T15:00:00Z` | 日期输入提示 |
| `Hex bytes, e.g. 01 ab ff` | `十六进制字节，例如 01 ab ff` | 数据输入提示 |
| `Value too large` | `值过大` | 值限制 |
| `Scalar values are limited to 64 KB in this editor.` | `此编辑器中的标量值上限为 64 KB。` | 值限制 |
| `Hex input is limited to 16 KB in this editor.` | `此编辑器中的十六进制输入上限为 16 KB。` | 值限制 |
| `Data values are limited to 4 KB in this editor.` | `此编辑器中的数据值上限为 4 KB。` | 值限制 |
| `Not a valid value` | `值无效` | 值校验 |
| `Expected: %@` | `应为：%@` | 值校验 |
| `Type of the new value` | `新值的类型` | 新增项目 |
| `New Item` | `新项目` | 新增项目 |
| `Key` | `键` | 新增/重命名 |
| `Key exists` | `键已存在` | 新增失败 |
| `There is already a key named \"%@\".` | `已存在名为“%@”的键。` | 新增失败 |
| `Rename Key` | `重命名键` | 重命名 |
| `XML` | `XML` | 格式名 |
| `Binary` | `二进制` | 格式名 |
| `OpenStep` | `OpenStep` | 格式名 |
| `Unknown` | `未知` | 格式名 |
| `The property list contains a nil value.` | `属性列表包含 nil 值。` | 解析/编码错误 |
| `A dictionary key is not a string.` | `字典键不是字符串。` | 解析/编码错误 |
| `The property list contains an unsupported value.` | `属性列表包含不支持的值。` | 解析/编码错误 |

## 4. 十六进制查看器与编辑器

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `Cannot open this file.` | `无法打开此文件。` | 打开失败 |
| `%@ · %llu bytes%@%@` | `%@ · %llu 字节%@%@` | 文件状态 |
| ` · %lu changed` | ` · 已更改 %lu 个字节` | 文件状态 |
| ` · Saving…` | ` · 正在保存…` | 文件状态 |
| `Discard Changes` | `放弃更改` | 编辑器菜单 |
| `Go to Offset…` | `前往偏移…` | 编辑器菜单 |
| `Find Hex Bytes…` | `查找十六进制字节…` | 编辑器菜单 |
| `Find Text…` | `查找文本…` | 编辑器菜单 |
| `Only the owner may read this file.` | `只有所有者可以读取此文件。` | 读取失败 |
| `Read failed: %@` | `读取失败：%@` | 读取失败 |
| `Bytes at 0x%llx` | `0x%llx 处的字节` | 覆盖对话框 |
| `Overwrite these %lu bytes (hex). The file size stays the same.` | `覆盖这 %lu 个字节（十六进制）。文件大小保持不变。` | 覆盖对话框 |
| `Not changed` | `未更改` | 覆盖失败 |
| `Enter exactly %lu bytes in hex.` | `请输入恰好 %lu 个字节的十六进制值。` | 覆盖校验 |
| `Wait for the save to finish before leaving or changing these edits.` | `请等待保存完成后再离开或更改这些编辑。` | 保存中提示 |
| `Save unavailable` | `无法保存` | 保存限制 |
| `The file version could not be verified. Close and reopen it before saving.` | `无法验证文件版本。请关闭并重新打开后再保存。` | 保存限制 |
| `%lu bytes in %@ are overwritten in place. The current file is backed up first.` | `将原地覆盖 %lu 个字节，涉及 %@。当前文件会先备份。` | 保存确认 |
| `Your byte changes have not been saved.` | `你的字节更改尚未保存。` | 放弃更改 |
| `Go to Offset` | `前往偏移` | 偏移对话框 |
| `Hex (0x1a2b) or decimal` | `十六进制（0x1a2b）或十进制` | 偏移输入提示 |
| `Invalid offset` | `偏移无效` | 偏移校验 |
| `Enter a complete non-negative decimal value or a 0x-prefixed hexadecimal value.` | `请输入完整的非负十进制值，或带 0x 前缀的十六进制值。` | 偏移校验 |
| `Offset unavailable` | `偏移不可用` | 偏移校验 |
| `The file is empty or its size is still loading.` | `文件为空，或大小仍在加载。` | 偏移校验 |
| `Offset out of range` | `偏移超出范围` | 偏移校验 |
| `Enter an offset from 0x0 through 0x%llx.` | `请输入 0x0 到 0x%llx 之间的偏移。` | 偏移校验 |
| `Find Hex Bytes` | `查找十六进制字节` | 查找对话框 |
| `Find Text` | `查找文本` | 查找对话框 |
| `Searches the saved file forward from the top of the screen.` | `从屏幕顶部开始，在已保存的文件中向前搜索。` | 查找说明 |
| `Search too large` | `搜索内容过大` | 查找限制 |
| `Use at most 1 MiB of UTF-8 search input.` | `UTF-8 搜索输入最多为 1 MiB。` | 查找限制 |
| `Nothing to find` | `没有可查找的内容` | 查找校验 |
| `Enter hex bytes, e.g. de ad be ef.` | `请输入十六进制字节，例如 de ad be ef。` | 查找校验 |
| `Enter some text.` | `请输入文本。` | 查找校验 |
| `Searching…` | `正在搜索…` | 查找状态 |
| `No match after offset 0x%llx.` | `偏移 0x%llx 之后没有匹配项。` | 查找结果 |

## 5. App 管理、备份与还原

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `Before restore` | `还原之前` | 自动安全备份原因 |
| `The backup folder cannot be read` | `无法读取备份文件夹` | 备份校验 |
| `The backup contains an unexpected item: %@` | `备份包含意外项目：%@` | 备份校验 |
| `The backup part %@ is not a directory` | `备份部分 %@ 不是文件夹` | 备份校验 |
| `The backup part %@ cannot be read: %@` | `无法读取备份部分 %@：%@` | 备份校验 |
| `The backup manifest does not match the on-disk parts` | `备份清单与磁盘上的部分不匹配` | 备份校验 |
| `The backup path is outside this app's backup folder` | `备份路径在此 App 的备份文件夹之外` | 备份校验 |
| `The backup folder is missing` | `缺少备份文件夹` | 备份校验 |
| `The backup manifest is not a regular file` | `备份清单不是普通文件` | 备份校验 |
| `The backup manifest is invalid` | `备份清单无效` | 备份校验 |
| `The safety backup has no typed manifest` | `安全备份没有类型化清单` | 备份校验 |
| `The legacy backup cannot be read` | `无法读取旧版备份` | 备份校验 |
| `The legacy backup contains an unexpected item: %@` | `旧版备份包含意外项目：%@` | 备份校验 |
| `invalid manifest` | `清单无效` | 备份校验 |
| ` (older, unverified)` | `（较旧，未验证）` | 备份标签 |
| `The app container no longer exists or is not a directory` | `App 容器已不存在或不是文件夹` | 容器校验 |
| `The app container was replaced after it was scanned` | `App 容器在扫描后被替换` | 容器校验 |
| `The app container identity no longer matches the selected app` | `App 容器标识不再匹配所选 App` | 容器校验 |
| `The copied tree could not be verified (the source changed or the copy is incomplete)` | `无法验证复制的目录树（源已更改或副本不完整）` | 复制校验 |
| `Some items remain in %@; keep the app closed and try again` | `%@ 中仍有部分项目；请保持 App 关闭后重试` | 清除校验 |
| `The app identifier is not a valid bundle identifier` | `App 标识符不是有效的 Bundle ID` | 备份校验 |
| `Cannot locate the app backup folder` | `无法找到 App 备份文件夹` | 备份错误 |
| `Cannot create the backup folder` | `无法创建备份文件夹` | 备份错误 |
| `Cannot hash the staged backup part` | `无法计算暂存备份部分的哈希` | 备份错误 |
| `The app data changed while it was being backed up; no snapshot-consistent copy was made` | `备份期间应用数据已更改，未创建快照一致的副本` | 备份错误 |
| `Cannot write the backup manifest` | `无法写入备份清单` | 备份错误 |
| `Cannot finish the backup (errno %d)` | `无法完成备份（errno %d）` | 备份错误 |
| `The app container changed while the backup was being finalized` | `完成备份时 App 容器已更改` | 备份错误 |
| `Finding apps…` | `正在查找 App…` | App 扫描状态 |
| `Finding apps… %lld%%` | `正在查找 App… %lld%%` | App 扫描状态 |
| `Measuring %lu/%lu…` | `正在测量 %lu/%lu…` | App 扫描状态 |
| `Unknown container (%@)` | `未知容器（%@）` | App 扫描状态 |
| `Container enumeration failed. See Log for the statfs/inode reason.` | `容器枚举失败。请查看日志中的 statfs/inode 原因。` | App 扫描错误 |
| `No app containers were found. Refresh, and check Log for the enumeration reason.` | `未找到 App 容器。请刷新，并查看日志中的枚举原因。` | App 扫描错误 |
| `%lu containers · %lu with limited access, identity, size, or no identifier. See Log.` | `%lu 个容器 · %lu 个存在访问、标识、大小或无标识符方面的限制。请查看日志。` | App 扫描摘要 |
| `The container identity is unavailable or changed. Backup, restore and clear are disabled for this entry.` | `容器标识不可用或已更改。此条目已禁用备份、还原和清除。` | 受限 App |
| `The container identifier is unavailable. Backup, restore and clear are disabled for this entry.` | `容器标识符不可用。此条目已禁用备份、还原和清除。` | 受限 App |
| `Sandbox access is unavailable. Check the App Group and see Log; only the container path can be copied.` | `沙盒访问不可用。请检查应用组并查看日志；目前只能复制容器路径。` | 受限 App |
| `Open Data Folder` | `打开数据文件夹` | App 操作表 |
| `Copy Container Path` | `复制容器路径` | App 操作表 |
| `Back Up Data` | `备份数据` | App 操作表 |
| `Restore Backup (%@)` | `还原备份（%@）` | App 操作表 |
| `Restore a Backup… (%lu)` | `还原备份…（%lu）` | App 操作表 |
| `Share Latest Backup (AirDrop…)` | `分享最新备份（隔空投送…）` | App 操作表 |
| `Clear Data…` | `清除数据…` | App 操作表 |
| `Backing up %@…` | `正在备份 %@…` | 备份状态 |
| `Backed up` | `已备份` | 备份结果 |
| `Backup failed` | `备份失败` | 备份结果 |
| `Saved to AppBackups/%@/%@` | `已保存到 AppBackups/%@/%@` | 备份结果 |
| `Nothing was saved: %@` | `未保存任何内容：%@` | 备份结果 |
| `Clearing %@…` | `正在清除 %@…` | 清除状态 |
| `Data cleared` | `数据已清除` | 清除结果 |
| `Partly cleared` | `部分清除` | 清除结果 |
| `Freed about %@.%@ Open %@ to start fresh.` | `已释放约 %@。%@ 打开 %@ 以重新开始。` | 清除结果 |
| ` %@. Keep the app closed and try again.` | ` %@。请保持 App 关闭后重试。` | 清除错误 |
| `Some items could not be removed (see Log)` | `某些项目无法移除（见日志）` | 清除错误 |
| `Clear %@?` | `清除 %@？` | 清除确认 |
| `Deletes everything in the app's Documents, Library and tmp, like a fresh install. The optional backup covers Documents and Library only; tmp is discarded and cannot be restored. Logins, settings and offline content are lost. Close the app first.` | `这会像全新安装一样删除 App 的 Documents、Library 和临时文件（tmp）中的所有内容。可选备份仅包含 Documents 和 Library；临时文件会被丢弃且无法还原。登录状态、设置和离线内容都会丢失。请先关闭此 App。` | 清除确认 |
| `Back Up, Then Clear` | `备份后清除` | 清除确认 |
| `Not cleared` | `未清除` | 清除结果 |
| `The backup did not complete, so nothing was deleted.` | `备份未完成，因此未删除任何内容。` | 清除结果 |
| `Clear Without Backup` | `不备份直接清除` | 清除确认 |
| `Restore which backup?` | `选择备份` | 选择备份 |
| `\n\nThis backup is unverified (%@). WQ Files will re-check its parts before changing anything.` | `\n\n此备份未验证（%@）。WQ Files 会在更改任何内容前重新检查其各部分。` | 还原警告 |
| `no typed manifest` | `没有类型化清单` | 还原警告 |
| `Restore %@?` | `还原“%@”备份？` | 还原确认 |
| `Replaces the app's current Documents and Library with the backup from %@; tmp is left untouched. The current data is backed up first, and put back if anything fails. Close the app first: a running app can make the operation non-snapshot-consistent.%@` | `将用来自 %@ 的备份替换 App 当前的 Documents 和 Library；临时文件（tmp）保持不变。当前数据会先备份，若任何步骤失败会还原。请先关闭此 App：运行中的 App 可能导致操作无法保持快照一致。%@` | 还原确认 |
| `Restoring %@…` | `正在还原 %@…` | 还原状态 |
| `Restored` | `还原成功` | 还原结果 |
| `Open %@ to use the restored Documents and Library. The data from before is kept as backup %@; tmp was not changed. Keep the app closed during this operation.%@` | `打开 %@ 以使用已还原的 Documents 和 Library。之前的数据会保留为备份 %@；临时文件（tmp）未更改。此操作期间请保持 App 关闭。%@` | 还原结果 |
| ` The recovery journal is committed and will be cleaned up at the next launch.` | ` 还原日志已提交，将在下次启动时清理。` | 还原结果 |
| `Not restored` | `未能还原` | 还原结果 |
| `The legacy backup is empty. Nothing was changed.` | `旧版备份为空，未更改任何内容。` | 还原失败 |
| `The selected app container is no longer safe to use (%@). Nothing was changed.` | `所选 App 容器已不再安全（%@），未更改任何内容。` | 还原失败 |
| `The current data couldn't be backed up first (%@). Nothing was changed.` | `无法先备份当前数据（%@），未更改任何内容。` | 还原失败 |
| `The recovery journal could not be written` | `无法写入还原日志` | 还原失败 |
| `The selected backup changed before restore` | `所选备份在还原前已更改` | 还原失败 |
| `The selected backup changed during restore` | `所选备份在还原期间已更改` | 还原失败 |
| `The restore finished, but its recovery journal could not be committed (%@)` | `还原已完成，但无法提交其还原日志（%@）` | 还原失败 |
| `Some files couldn't be written` | `某些文件无法写入` | 还原失败 |
| ` The recovery journal is committed and will be cleaned up at the next launch.` | ` 还原日志已提交，将在下次启动时清理。` | 还原结果 |
| ` Recovery will run again at the next launch because the journal could not be removed.` | ` 由于无法移除还原日志，下次启动时将再次执行还原。` | 还原回滚 |
| ` Recovery will run again at the next launch.` | ` 下次启动时将再次执行还原。` | 还原回滚 |
| `Automatic recovery of %@ failed: %@. The safety backup is %@; see Log.` | `%@ 的自动还原失败：%@。安全备份位于 %@；见日志。` | 启动还原 |
| `An interrupted restore was found with an unknown recovery state. The journal was retained for manual recovery.` | `发现一次中断的还原，其还原状态未知。还原日志已保留，供手动还原。` | 启动还原 |
| `An interrupted restore was found, but its recovery journal is invalid. The journal was retained for manual recovery%@.` | `发现一次中断的还原，但其还原日志无效。还原日志已保留，供手动还原%@。` | 启动还原 |
| `An interrupted restore of %@ was recovered, but its journal could not be committed (%@). It will be checked again at the next launch.` | `%@ 的中断还原已完成，但无法提交其还原日志（%@）。下次启动时会再次检查。` | 启动还原 |
| `An interrupted restore of %@ was recovered. Its committed journal will be cleaned up at the next launch (%@).` | `%@ 的中断还原已完成。已提交的还原日志将在下次启动时清理（%@）。` | 启动还原 |
| `An interrupted restore of %@ was recovered from its safety backup.` | `%@ 的中断还原已通过其安全备份完成。` | 启动还原 |
| `The backup is not safe to restore (%@). Nothing was changed.` | `此备份无法安全还原（%@），未更改任何内容。` | 还原失败 |
| `The selected backup changed before restore` | `所选备份在还原前已更改` | 还原失败 |
| `The selected backup changed during restore` | `所选备份在还原期间已更改` | 还原失败 |
| `Restore failed` | `还原失败` | 还原结果 |
| `Not restored` | `未能还原` | 还原结果 |

| `%lu of %lu apps` | `%lu / %lu 个 App` | Apps 页标题 |
| `%lu apps · %@ of app data` | `%lu 个 App · 应用数据共 %@` | Apps 页标题 |
| `Tap an app to back up, restore or clear its Documents and Library. Close the app first (swipe it away in the app switcher); operations are not snapshot-consistent while it runs. Backups are stored in WQFiles/AppBackups and are visible in the Files app. tmp is cleared when requested but is not backed up or restored.` | `点按 App 可备份、还原或清除其 Documents 和 Library。请先关闭 App（在 App 切换器中向上轻扫）；App 运行时操作无法保持快照一致。备份存储在 WQFiles/AppBackups，可在“文件”App 中查看。临时文件（tmp）会在请求清除时删除，但不会备份或还原。` | Apps 页说明 |
| `Restore which backup?` | `选择备份` | 选择 App 备份 |
| `Restore %@?` | `还原“%@”备份？` | App 备份还原确认 |
| `Restore Backup (%@)` | `还原备份（%@）` | App 操作表 |
| `Restore a Backup… (%lu)` | `还原备份…（%lu）` | App 操作表 |
| `Restoring %@…` | `正在还原 %@…` | App 还原状态 |
| `Restored` | `还原成功` | App 还原结果 |
| `Not restored` | `未能还原` | App 还原结果 |
| `Restore failed` | `还原失败` | App 还原结果 |
| `Restore` | `还原备份` | App 还原确认按钮 |
| `The container identity is unavailable or changed. Backup, restore and clear are disabled for this entry.` | `容器标识不可用或已更改。此条目已禁用备份、还原和清除。` | 受限 App |
| `The container identifier is unavailable. Backup, restore and clear are disabled for this entry.` | `容器标识符不可用。此条目已禁用备份、还原和清除。` | 受限 App |

## 6. 缓存清理

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `Cache Cleaner` | `缓存清理` | 页面标题 |
| `Search apps` | `搜索 App` | 搜索框 |
| `Finding apps…` | `正在查找 App…` | 扫描状态 |
| `Finding %@… %lld%%` | `正在查找 %@… %lld%%` | 扫描状态 |
| `Measuring %@ %lu of %lu…` | `正在测量 %@ %lu / %lu…` | 扫描状态 |
| `Cleaning` | `正在清理` | 行状态 |
| `Scanning` | `正在扫描` | 行状态 |
| `Reclaimable` | `可释放` | 摘要 |
| `summary` | `摘要` | 内部节标题（仅在显示时翻译） |
| `Delete Library/Caches and tmp for %lu app%@, plus Crash Logs` | `删除 %lu 个 App%@ 的缓存（Library/Caches）和临时文件（tmp），并删除崩溃日志` | 清理范围 |
| `Delete Library/Caches and tmp for %lu app%@` | `删除 %lu 个 App%@ 的缓存（Library/Caches）和临时文件（tmp）` | 清理范围 |
| `Delete Crash Logs` | `删除崩溃日志` | 清理范围 |
| `Delete the selected cache targets` | `删除所选缓存目标` | 清理范围 |
| `Clears each selected app's Library/Caches and tmp, and deletes selected Crash Logs. Apps rebuild their caches as you use them; some keep offline content (music, maps, downloads) there and will download it again. No backup is kept.` | `清除每个所选 App 的缓存（Library/Caches）和临时文件（tmp），并删除所选崩溃日志。App 会在使用过程中重建缓存；部分 App 会在其中保留离线内容（音乐、地图、下载），之后会重新下载。不会保留备份。` | 清理说明 |
| `Clears each selected app's Library/Caches and tmp. Apps rebuild their caches as you use them; some keep offline content (music, maps, downloads) there and will download it again. No backup is kept.` | `清除每个所选 App 的缓存（Library/Caches）和临时文件（tmp）。App 会在使用过程中重建缓存；部分 App 会在其中保留离线内容（音乐、地图、下载），之后会重新下载。不会保留备份。` | 清理说明 |
| `Deletes selected Crash Logs. This cannot be undone. No backup is kept.` | `删除所选崩溃日志。此操作无法撤销，且不会保留备份。` | 清理说明 |
| `Select app caches or Crash Logs to see the deletion scope. No backup is kept.` | `选择 App 缓存或崩溃日志以查看删除范围。不会保留备份。` | 清理说明 |
| `Select All` | `全选` | 选择菜单 |
| `Select None` | `全不选` | 选择菜单 |
| `Select Large Caches (50 MB+)` | `选择大型缓存（50 MB 以上）` | 选择菜单 |
| `No %@ container%@ found.` | `未找到 %@ 容器%@。` | 扫描结果 |
| `Scan incomplete: %@. See Log.` | `扫描不完整：%@。请查看日志。` | 扫描结果 |
| `limited rows are excluded; the remaining rows can still be cleaned` | `受限行已排除；其余行仍可清理` | 扫描说明 |
| `Crash Logs` | `崩溃日志` | 分类 |
| `Crash Logs · osanalytics` | `崩溃日志 · osanalytics` | 崩溃日志分类 |
| `Crash Logs · access limited` | `崩溃日志 · 访问受限` | 崩溃日志分类 |
| `cache %@ · temp %@%@` | `缓存 %@ · 临时 %@%@` | 行详情 |
| ` · access limited` | ` · 访问受限` | 行详情 |
| `Not cleanable` | `无法清理` | 受限行 |
| `This row has incomplete access or identity information. Scan again while the app is closed, or use its file browser entry to inspect it.` | `此行的访问或标识信息不完整。请在 App 关闭时重新扫描，或使用其文件浏览器条目进行检查。` | 受限行 |
| `Show Crash Logs in File Browser` | `在文件浏览器中显示崩溃日志` | 长按菜单 |
| `Show Caches in File Browser` | `在文件浏览器中显示缓存` | 长按菜单 |
| ` · Caches` | ` · 缓存` | 文件浏览器名称 |
| `Show tmp in File Browser` | `在文件浏览器中显示临时文件` | 长按菜单 |
| ` · tmp` | ` · 临时文件` | 文件浏览器名称 |
| `Show App Data in File Browser` | `在文件浏览器中显示应用数据` | 长按菜单 |
| `Stopping after the current item…` | `完成当前项目后停止…` | 停止状态 |
| `Clean caches?` | `清理缓存？` | 清理确认 |
| `%@, about %@? This cannot be undone. Close the selected apps first; you can stop between items.` | `%@，约 %@？此操作无法撤销。请先关闭所选 App；你可以在项目之间停止。` | 清理确认 |
| `Cleaning…` | `正在清理…` | 清理状态 |
| `Clean cancelled: %@. Scan again before retrying.` | `清理已取消：%@。请在重试前重新扫描。` | 清理结果 |
| `Cleaning %lu of %lu: %@` | `正在清理 %lu / %lu：%@` | 清理状态 |
| `Stopped. Freed %@.%@` | `已停止。已释放 %@。%@` | 清理结果 |
| ` Some items could not be removed (see Log).` | ` 某些项目无法移除（见日志）。` | 清理警告 |
| `Clean stopped: %@. Scan again before retrying.` | `清理已停止：%@。请在重试前重新扫描。` | 清理结果 |
| `Freed %@.%@` | `已释放 %@。%@` | 清理结果 |
| ` Close running apps first.` | ` 请先关闭正在运行的 App。` | 清理说明 |

| `%lu of %lu` | `%lu / %lu` | 搜索结果标题 |
| `%lu apps and extensions` | `%lu 个 App 和扩展` | 缓存页标题 |
| `%lu container enumeration%@ failed` | `%lu 个容器枚举失败%@` | 扫描摘要 |
| `%lu container%@ had limited access` | `%lu 个容器访问受限%@` | 扫描摘要 |
| `%lu cache tree measurement%@ was limited` | `%lu 个缓存目录测量受限%@` | 扫描摘要 |
| `%lu container%@ had no identifier or identity` | `%lu 个容器没有标识符或标识%@` | 扫描摘要 |
| `%@ selected in %lu item%@` | `已选择 %@，共 %lu 个项%@` | 缓存摘要 |
| `cache %@ · temp %@%@` | `缓存 %@ · 临时文件 %@%@` | 缓存行详情 |

## 7. 分享与压缩

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `Share in progress` | `正在分享` | 分享冲突 |
| `Wait for the current share to finish before starting another.` | `请等待当前分享完成后再开始另一个。` | 分享冲突 |
| `Only regular files can be shared.` | `只能分享普通文件。` | 分享限制 |
| `Cannot share` | `无法分享` | 分享失败 |
| `Could not create a temporary export folder` | `无法创建临时导出文件夹` | 分享失败 |
| `Preparing…` | `正在准备…` | 压缩中 |
| `Compressing the folder` | `正在压缩文件夹` | 压缩中 |
| `Could not create the ZIP` | `无法创建 ZIP` | 压缩失败 |

## 8. 通用错误与安全提示

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `Out of memory` | `内存不足` | 分配失败 |
| `Cannot allocate a backup name.` | `无法分配备份名称。` | 备份失败 |
| `Not enough free space for a full backup copy` | `可用空间不足，无法创建完整备份副本` | 备份失败 |
| `The file changed after it was opened. Your edits were not written; reopen it and compare the changes.` | `文件在打开后已更改。你的编辑未写入，请重新打开并比较更改。` | 保存冲突 |
| `The target path was replaced during writing` | `写入期间目标路径已被替换` | 保存冲突 |
| `Saved contents could not be verified; possible concurrent modification` | `无法验证已保存的内容；可能存在并发修改` | 保存冲突 |
| `Write failed` | `写入失败` | 保存错误 |
| `Close failed: %@. Backup: %@` | `关闭失败：%@。备份：%@` | 保存错误 |
| `The path is invalid or belongs to backup storage.` | `路径无效，或属于备份存储。` | 路径校验 |
| `Backup storage cannot be modified through the file browser.` | `不能通过文件浏览器修改备份存储。` | 安全限制 |
| `Backup storage cannot be overwritten or deleted through the file browser.` | `不能通过文件浏览器覆盖或删除备份存储。` | 安全限制 |
| `Backup storage cannot be renamed through the file browser.` | `不能通过文件浏览器重命名备份存储。` | 安全限制 |
| `Source and destination are the same file` | `源文件和目标文件相同` | 复制错误 |
| `The source changed while it was being copied` | `复制期间源文件已更改` | 复制错误 |
| `The source changed while it was copied` | `复制期间源文件已更改` | 复制错误 |
| `Destination is not a regular file` | `目标不是普通文件` | 复制错误 |
| `Invalid copy path` | `复制路径无效` | 复制错误 |
| `Cannot inspect the copy source` | `无法检查复制源` | 复制错误 |
| `Source and destination trees overlap or have invalid paths` | `源目录树和目标目录树重叠，或路径无效` | 文件夹复制 |
| `Cannot safely open distinct source and destination folders` | `无法安全地打开不同的源文件夹和目标文件夹` | 文件夹复制 |
| `Cannot read the source folder` | `无法读取源文件夹` | 文件夹复制 |
| `A copy root changed during copying` | `复制期间复制根目录已更改` | 文件夹复制 |
| `Invalid file path` | `文件路径无效` | 路径校验 |
| `Invalid folder path` | `文件夹路径无效` | 路径校验 |
| `Invalid name` | `名称无效` | 重命名校验 |
| `Only empty folders can be deleted` | `只能删除空文件夹` | 删除校验 |
| `Only a complete backup unit can be deleted here.` | `此处只能删除完整的备份单元。` | 删除校验 |
| `Could not remove everything inside the backup.` | `无法移除备份中的所有内容。` | 删除错误 |
| `An item with that name already exists` | `已存在同名项目` | 重命名错误 |
| `A change lies past the end of the file` | `有更改超出文件末尾` | 十六进制/保存校验 |
| `This app needs an App Group to reach other folders. Re-sign it with a tool that keeps the App Group entitlement.` | `此 App 需要应用组才能访问其他文件夹。请使用保留应用组权限（entitlement）的工具重新签名。` | 启动提示 |
| `App-group cache recovery requires attention; preserved contents retained: %@ (%@)` | `应用组缓存需要修复；已保留内容：%@（%@）` | 启动提示 |
| `The backup manifest is not a dictionary` | `备份清单不是字典` | 备份校验 |
| `The backup manifest is not marked complete` | `备份清单未标记为完整` | 备份校验 |
| `The backup manifest format is unsupported` | `备份清单格式不受支持` | 备份校验 |
| `The backup manifest belongs to another app` | `备份清单属于另一个 App` | 备份校验 |
| `The backup manifest has no valid creation timestamp` | `备份清单没有有效的创建时间` | 备份校验 |
| `The backup manifest reason is malformed` | `备份清单的原因字段格式错误` | 备份校验 |
| `The backup manifest sequence is malformed` | `备份清单的序号格式错误` | 备份校验 |
| `The backup manifest parts are malformed` | `备份清单的部分字段格式错误` | 备份校验 |
| `The backup manifest contains an invalid or duplicate part` | `备份清单包含无效或重复的部分` | 备份校验 |
| `The backup manifest hashes are malformed` | `备份清单的哈希格式错误` | 备份校验 |
| `The backup manifest hashes do not match its parts` | `备份清单的哈希与部分不匹配` | 备份校验 |
| `The backup manifest has an invalid part hash` | `备份清单包含无效的部分哈希` | 备份校验 |
| `An interrupted restore is still active. Recover or discard it before starting another restore` | `仍有中断的还原处于活动状态。请先还原或丢弃它，再开始新的还原` | 还原日志 |
| `The existing restore recovery journal has an unknown state` | `现有还原日志处于未知状态` | 还原日志 |
| `The restore paths are not inside this app's backup folder` | `还原路径不在此 App 的备份文件夹内` | 还原校验 |
| `The backup has no hash for %@` | `备份中没有 %@ 的哈希` | 还原校验 |
| `The backup's %@ contents changed after it was created` | `备份的 %@ 内容在创建后已更改` | 还原校验 |

## 9. 内置系统服务名称

`WQLaunchServices.m` 里有一张系统服务名称回退表。系统能提供本地化名称时会优先使用系统名称；下面是回退表中建议显示的中文。品牌名和无法确定官方中文名的内部服务保留英文。

| 原文 | 建议中文 | 说明 |
|---|---|---|
| `App Store` | `App Store` | 品牌名保留 |
| `Safari` | `Safari` | 品牌名保留 |
| `Weather` | `天气` | Apple 官方名称 |
| `News` | `新闻` | Apple 官方名称 |
| `Stocks` | `股市` | Apple 官方名称 |
| `Mail` | `邮件` | Apple 官方名称 |
| `Messages` | `信息` | Apple 官方名称 |
| `Phone` | `电话` | Apple 官方名称 |
| `Photos` | `照片` | Apple 官方名称 |
| `Camera` | `相机` | Apple 官方名称 |
| `Calendar` | `日历` | Apple 官方名称 |
| `Notes` | `备忘录` | Apple 官方名称 |
| `Reminders` | `提醒事项` | Apple 官方名称 |
| `Maps` | `地图` | Apple 官方名称 |
| `Music` | `音乐` | Apple 官方名称 |
| `TV` | `Apple TV` | 采用 App 名称 |
| `Podcasts` | `播客` | Apple 官方名称 |
| `Books` | `图书` | Apple 官方名称 |
| `Health` | `健康` | Apple 官方名称 |
| `Wallet` | `钱包` | Apple 官方名称 |
| `Settings` | `设置` | Apple 官方名称 |
| `Clock` | `时钟` | Apple 官方名称 |
| `Calculator` | `计算器` | Apple 官方名称 |
| `Compass` | `指南针` | Apple 官方名称 |
| `Voice Memos` | `语音备忘录` | Apple 官方名称 |
| `FaceTime` | `FaceTime` | 品牌名保留 |
| `Contacts` | `通讯录` | Apple 官方名称 |
| `Files` | `文件` | Apple 官方名称 |
| `Find My` | `查找` | Apple 官方名称 |
| `Home` | `家庭` | Apple 官方名称 |
| `Shortcuts` | `快捷指令` | Apple 官方名称 |
| `Translate` | `翻译` | Apple 官方名称 |
| `Fitness` | `健身` | Apple 官方名称 |
| `Watch` | `Watch` | 品牌名保留 |
| `Freeform` | `无边记` | Apple 官方名称 |
| `Journal` | `日志` | Apple 官方名称 |
| `Passwords` | `密码` | Apple 官方名称 |
| `Measure` | `测距仪` | Apple 官方名称 |
| `Magnifier` | `放大器` | Apple 官方名称 |
| `Tips` | `提示` | Apple 官方名称 |
| `Siri` | `Siri` | 品牌名保留 |
| `Games` | `游戏` | Apple 官方名称 |
| `Game Center` | `游戏中心` | Apple 官方名称 |
| `Image Playground` | `图像游乐场` | Apple 官方名称 |
| `Keynote` | `Keynote` | 品牌名保留 |
| `Pages` | `Pages` | 品牌名保留 |
| `Numbers` | `Numbers` | 品牌名保留 |
| `Find iPhone` | `查找 iPhone` | Apple 官方名称 |
| `Apple Store` | `Apple Store` | 品牌名保留 |
| `Apple Support` | `Apple 支持` | Apple 官方名称 |
| `Diagnostics` | `诊断` | 系统服务 |
| `Wallpaper` | `墙纸` | 系统服务 |
| `Wallpaper (Mercury)` | `墙纸（Mercury）` | 系统服务 |
| `Wallpaper Collections` | `墙纸集` | 系统服务 |
| `Photo Wallpaper` | `照片墙纸` | 系统服务 |
| `Widgets` | `小组件` | 系统服务 |
| `Screenshots` | `截屏` | 系统服务 |
| `AirDrop` | `隔空投送` | Apple 官方名称 |
| `Apple Media Services` | `Apple 媒体服务` | 系统服务 |
| `Assistive Access Camera` | `辅助访问相机` | 系统服务 |
| `Assistive Access Photos` | `辅助访问照片` | 系统服务 |
| `Voice Assistant` | `语音助手` | 系统服务 |
| `Shazam` | `Shazam` | 品牌名保留 |
| `Screen Time` | `屏幕使用时间` | Apple 官方名称 |
| `Remote Setup` | `远程设置` | 系统服务 |
| `Demo` | `演示` | 系统服务 |
| `Apple Account` | `Apple 账户` | Apple 官方名称 |
| `Account Sign-In` | `账户登录` | 系统服务 |
| `App Store Sheets` | `App Store 表单` | 系统服务 |
| `New Device Setup` | `新设备设置` | 系统服务 |
| `Printing` | `打印` | 系统服务 |
| `Events` | `事件` | 系统服务 |
| `Media Picker` | `媒体选择器` | 系统服务 |
| `Smart Card` | `智能卡` | 系统服务 |
| `Call Screen` | `通话界面` | 系统服务 |
| `SpringBoard` | `SpringBoard` | 内部组件名保留 |
| `Safari View` | `Safari 视图` | 系统服务 |
| `Message Compose` | `信息撰写` | 系统服务 |
| `Companion` | `Companion` | 内部服务名保留 |
| `Music Recognition` | `音乐识别` | 系统服务 |
| `Font Install` | `字体安装` | 系统服务 |
| `Continuity Markup` | `连续互通标记` | 系统服务 |
| `Apple Cash Stickers` | `Apple Cash 贴纸` | 系统服务 |
| `Apple TV Setup` | `Apple TV 设置` | 系统服务 |
| `Hearing` | `听力` | 系统服务 |
| `Companion Setup` | `Companion 设置` | 内部服务名保留 |
| `CarPlay Wallpaper` | `CarPlay 墙纸` | 系统服务 |
| `iCloud Sharing` | `iCloud 共享` | 系统服务 |
| `Enhanced Logging` | `增强日志记录` | 系统服务 |
| `Privacy Prompts` | `隐私提示` | 系统服务 |
| `Content Filter` | `内容过滤器` | 系统服务 |
| `Quick Note` | `快速备忘录` | 系统服务 |
| `Headphones` | `耳机` | 系统服务 |
| `Data Detectors` | `数据检测器` | 系统服务 |
| `Apple Pay` | `Apple Pay` | 品牌名保留 |
| `Wi-Fi Login` | `Wi-Fi 登录` | 系统服务 |
| `Tire Pressure` | `胎压` | 系统服务 |
| `Authentication` | `认证` | 系统服务 |
| `Messages Alerts` | `信息提醒` | 系统服务 |
| `Accessory Source` | `配件来源` | 系统服务 |
| `Print Center` | `打印中心` | 系统服务 |
| `Code Scanner` | `代码扫描器` | 系统服务 |
| `Widget Snapshots` | `小组件快照` | 系统服务 |
| `Restrictions` | `限制` | 系统服务 |
| `Car Radio` | `车载收音机` | 系统服务 |
| `Wallet Sheets` | `钱包表单` | 系统服务 |
| `Spotlight` | `聚焦` | Apple 官方名称 |
| `Keyboard` | `键盘` | 系统服务 |

## v0.8 新增界面与字符串

以下内容是拉取最新 `main` 后新增的 0.8 界面，已补入对照范围。

### 排序与列表

| 原文 | 建议中文 | 上下文 |
|---|---|---|
| `Sort By` | `排序方式` | 文件夹/Apps 排序菜单 |
| `Name` | `名称` | 排序依据 |
| `Date Modified` | `修改日期` | 文件夹排序 |
| `Date Created` | `创建日期` | 文件夹排序 |
| `Size` | `大小` | 文件夹/Apps 排序 |
| `Folders on Top` | `文件夹置顶` | 文件夹排序 |
| `A–Z` | `A–Z` | 名称升序 |
| `Z–A` | `Z–A` | 名称降序 |
| `Smallest first` | `最小优先` | 大小升序 |
| `Largest first` | `最大优先` | 大小降序 |
| `Oldest first` | `最早优先` | 日期升序 |
| `Newest first` | `最新优先` | 日期降序 |
| `created ` | `创建时间：` | 文件列表日期前缀 |
| `Apps aren't listed yet: this needs a scan of all files. Pull down to start it.` | `尚未列出 App：此操作需要扫描所有文件。下拉开始扫描。` | Apps 未列出 |
| `Not listed yet: this needs a scan of all files. Pull down to start it.` | `尚未列出：此操作需要扫描所有文件。下拉开始扫描。` | 文件夹未列出 |

### 扫描所有文件

| 原文 | 建议中文 | 上下文 |
|---|---|---|
| `Scan all files?` | `扫描所有文件？` | 扫描确认标题 |
| `Not Now` | `暂不` | 扫描确认 |
| `Start Scan` | `开始扫描` | 扫描确认 |
| `To list %@, WQ Files has to check every file on this device once: %@ files, %@.\n\nThis is only needed the first time; later scans only check new files and take seconds.\n\nKeep WQ Files open while it scans.` | `要列出 %@，WQ Files 需要先检查此设备上的每个文件一次：%@ 个文件，%@。\n\n只有第一次需要这样做；后续扫描只检查新文件，只需几秒。\n\n扫描期间请保持 WQ Files 打开。` | 扫描确认说明 |
| `Scanning all files` | `正在扫描文件` | 扫描窗口标题 |
| `iOS doesn't let WQ Files list these folders directly, so it checks every file on this device once. This is only slow the first time: later scans only check new files.\n\nKeep WQ Files open. Switching to another app or locking the screen pauses the scan.` | `iOS 不允许 WQ Files 直接列出这些文件夹，因此它需要先检查此设备上的每个文件一次。只有第一次较慢；后续扫描只检查新文件。\n\n请保持 WQ Files 打开。切换到其他 App 或锁屏会暂停扫描。` | 扫描窗口说明 |
| `Starting…` | `正在启动…` | 扫描状态 |
| `Hide` | `隐藏` | 扫描窗口 |
| `Stop Scan` | `停止扫描` | 扫描窗口 |
| `Hide keeps the scan running; the list fills in when it's done.` | `隐藏后扫描会继续运行；完成后列表会自动填充。` | 扫描窗口说明 |
| `about a minute` | `约 1 分钟` | 预计时间 |
| `about %.0f minutes` | `约 %.0f 分钟` | 预计时间 |
| `about %.1f hours` | `约 %.1f 小时` | 预计时间 |
| `%.0f million` | `%.0f 百万` | 文件数量 |
| ` · %@ left` | ` · 剩余 %@` | 扫描进度 |
| `the app folders` | `App 文件夹` | 扫描对象 |

### 签名检查

| 原文 | 建议中文 | 上下文 |
|---|---|---|
| `Signing problem: no App Group` | `签名问题：缺少应用组` | 启动提示 |
| `WQ Files needs an App Group to reach other apps' folders, and the tool that signed it removed it. Without it nothing can be opened, and app lists stay empty or show "NO TOKEN".\n\nRe-install WQ Files with AltStore, SideStore or Sideloadly (they create the App Group), or with a provisioning profile that contains one. Wildcard certificates (as used by many Feather/ESign setups) can't.` | `WQ Files 需要应用组（App Group）才能访问其他应用的文件夹，而签名工具把它移除了。没有它，任何内容都无法打开，应用列表会为空或显示“无令牌”。\n\n请使用 AltStore、SideStore 或 Sideloadly 重新安装 WQ Files（它们会创建应用组），或使用包含应用组的描述文件。通配符证书（许多 Feather/ESign 方案使用）无法做到。` | 启动提示 |
| `Signing Help` | `签名帮助` | 启动提示按钮 |
| `WQ Files %@ (%@) by kolbicz` | `WQ Files %@（%@），作者 kolbicz` | 启动页署名 |

### SQLite 查看器

| 原文 | 建议中文 | 上下文 |
|---|---|---|
| `SQLite Viewer` | `SQLite 查看器` | 打开方式 |
| `SQL` | `SQL` | 查询页标题/按钮 |
| `Copy` | `复制` | 行值菜单 |
| `CSV` | `CSV` | 导出按钮 |
| `Run` | `运行` | 查询按钮 |
| `Result` | `结果` | 查询结果标题 |
| `Tables and views` | `表和视图` | 列表标题 |
| `Copying and opening…` | `正在复制并打开…` | 加载状态 |
| `Cannot open this database: ` | `无法打开此数据库：` | 打开失败 |
| `No tables` | `没有表` | 空数据库 |
| `view` | `视图` | 表/视图行 |
| `%@ rows` | `%@ 行` | 表行数 |
| `%lu%@ rows · %lu columns` | `%lu%@ 行 · %lu 列` | 结果标题 |
| ` (first %lu)` | `（前 %lu 行）` | 结果限制 |
| `Row %ld` | `第 %ld 行` | 单行详情 |
| `No rows` | `没有行` | 空结果 |
| `Only read-only statements can run here.` | `此处只能运行只读语句。` | 查询限制 |
| `Only read-only statements (SELECT, read-only PRAGMA, EXPLAIN) can run here.` | `此处只能运行只读语句（SELECT、只读 PRAGMA、EXPLAIN）。` | 查询限制 |
| `Nothing to run.` | `没有可运行的语句。` | 查询校验 |
| `Run one statement at a time.` | `一次只能运行一条语句。` | 查询校验 |
| `This statement returns no rows.` | `此语句不返回任何行。` | 查询校验 |
| `Cannot run` | `无法运行` | 查询错误 |
| `Cannot export` | `无法导出` | CSV 错误 |
| `Read-only. This is a copy of the database%@ made when it was opened; the app's own file is not changed. Close the app first for an up-to-date copy.` | `只读。这是打开数据库时创建的副本%@；App 自己的文件不会被更改。要获得最新副本，请先关闭 App。` | 只读说明 |
| ` and its -wal file` | `及其 -wal 文件` | 只读说明 |
| `cannot create the temporary copy` | `无法创建临时副本` | 打开错误 |
| `cannot write the temporary copy` | `无法写入临时副本` | 打开错误 |
| `read failed` | `读取失败` | 打开错误 |
| `write failed` | `写入失败` | 打开错误 |
| `cannot create a temporary folder` | `无法创建临时文件夹` | 打开错误 |
| `cannot open the database` | `无法打开数据库` | 打开错误 |
| `cannot create the CSV file` | `无法创建 CSV 文件` | 导出错误 |
| `NULL` | `NULL` | 数据库空值 |
| `<binary plist, %d bytes>` | `<二进制 plist，%d 字节>` | 数据值 |
| `<%d bytes> %@` | `<%d 字节> %@` | 数据值 |
| `<text not UTF-8>` | `<非 UTF-8 文本>` | 文本值 |
| `base64:` | `base64:` | 二进制导出值，保留 |

## v0.8-b36 新增界面与字符串

### 媒体播放器

| 原文 | 建议中文 | 上下文 |
|---|---|---|
| `Media Player` | `媒体播放器` | 打开方式 |
| `Cannot play` | `无法播放` | 媒体打开失败 |
| `The file could not be read.` | `无法读取文件。` | 媒体打开失败 |

### 导入、选择与移动

| 原文 | 建议中文 | 上下文 |
|---|---|---|
| `Import Files` | `导入文件` | 文件菜单 |
| `Import Folder` | `导入文件夹` | 文件菜单 |
| `Importing` | `正在导入` | 导入进度 |
| `Import failed` | `导入失败` | 导入结果 |
| `Imported %lu files. %lu had a name that was already taken and got a number added.` | `已导入 %lu 个文件。%lu 个文件因名称已被占用而自动添加了编号。` | 多文件导入结果 |
| `No free name in this folder` | `此文件夹中没有可用名称` | 导入失败 |
| `A folder with the same name already existed, so the import is named %@.` | `已存在同名文件夹，因此导入项命名为 %@。` | 文件夹导入结果 |
| `Select Items` | `选择项目` | 多选模式 |
| `%lu Selected` | `已选择 %lu 项` | 多选标题 |
| `Move` | `移动` | 工具栏 |
| `Move…` | `移动…` | 菜单 |
| `Moving “%@”` | `正在移动“%@”` | 移动提示 |
| `Moving %lu items` | `正在移动 %lu 个项目` | 移动提示 |
| `Move %lu items` | `移动 %lu 个项目` | 移动提示 |
| `Move Here` | `移动到这里` | 目标文件夹工具栏 |
| `Open the folder you want to move to, then tap Move Here at the bottom. Any app's folder works.` | `打开要移动到的文件夹，然后点按底部的“移动到这里”。任何应用的文件夹都可以。` | 移动提示 |
| `Cannot move` | `无法移动` | 移动失败 |
| `Delete “%@”?` | `删除“%@”？` | 单文件删除确认 |
| `Delete %lu items?` | `删除 %lu 个项目？` | 多选删除确认 |
| `Files are copied to Backups first. Folders are deleted only when they are empty.` | `文件会先复制到“备份”。仅当文件夹为空时才会删除。` | 删除确认 |

### 压缩与解压

| 原文 | 建议中文 | 上下文 |
|---|---|---|
| `Compress` | `压缩` | 工具栏/菜单 |
| `Extract` | `解压` | ZIP 菜单 |
| `Compressing` | `正在压缩` | 压缩进度 |
| `Extracting` | `正在解压` | 解压进度 |
| `Cannot compress` | `无法压缩` | 压缩失败 |
| `Cannot extract` | `无法解压` | 解压失败 |
| `Created %@. %lu symbolic link%@ or special file%@ were left out.` | `已创建 %@。已排除 %lu 个符号链接%@或特殊文件%@。` | 压缩结果 |
| `Extracted %lu file%@ into %@. %lu symbolic link%@ in the ZIP were left out.` | `已将 %lu 个文件%@解压到 %@。ZIP 中的 %lu 个符号链接%@已排除。` | 解压结果 |
| `Copying failed.` | `复制失败。` | 解压失败 |
| `Can't create a temporary folder` | `无法创建临时文件夹` | 压缩/解压失败 |
| `Not a ZIP file` | `不是 ZIP 文件` | ZIP 校验 |
| `Can't read the ZIP file` | `无法读取 ZIP 文件` | ZIP 校验 |
| `The ZIP file is damaged (bad directory)` | `ZIP 文件已损坏（目录错误）` | ZIP 校验 |
| `The ZIP file is damaged (bad entry)` | `ZIP 文件已损坏（条目错误）` | ZIP 校验 |
| `The ZIP file is damaged (checksum mismatch)` | `ZIP 文件已损坏（校验和不匹配）` | ZIP 校验 |
| `This ZIP is encrypted, which isn't supported.` | `此 ZIP 已加密，暂不支持。` | ZIP 校验 |
| `This ZIP uses a compression method that isn't supported (%u).` | `此 ZIP 使用了不受支持的压缩方式（%u）。` | ZIP 校验 |
| `The ZIP contains an unsafe name (%@); nothing was extracted.` | `ZIP 包含不安全的名称（%@）；未解压任何内容。` | ZIP 安全校验 |
| `Not enough free space to extract this ZIP` | `可用空间不足，无法解压此 ZIP` | ZIP 空间校验 |
| `Extraction failed` | `解压失败` | 解压结果 |

### Apps 筛选

| 原文 | 建议中文 | 上下文 |
|---|---|---|
| `All Apps` | `所有应用` | Apps 筛选 |
| `Apple Apps` | `Apple 应用` | Apps 筛选 |
| `Other Apps` | `其他应用` | Apps 筛选 |
| `Backed Up` | `已备份` | Apps 筛选 |
| `Show` | `显示` | 筛子菜单 |
| `Copy Bundle ID` | `复制 Bundle ID` | App 长按菜单 |
| `%@ of data` | `%@ 数据` | App 操作表 |
| `WQ Files has no App Group, so it can't open other apps' folders. Re-sign it with a tool that keeps the App Group (see Signing in the README).` | `WQ Files 没有应用组，因此无法打开其他应用的文件夹。请使用保留应用组的工具重新签名（见 README 的 Signing 部分）。` | Apps 未列出 |

## 10. 不翻译的内容

以下内容保持不变，避免破坏功能或排查信息：

- 绝对路径，例如 `/private/var/...`、`Library/Caches`、`tmp`、`AppBackups`。
- Bundle ID，例如 `com.apple...`、`cz.kolbi.wqfiles`。
- plist 键名和备份清单字段，例如 `BundleID`、`PartHashes`、`ContainerInode`。
- SF Symbols 名称，例如 `folder.fill`、`arrow.uturn.backward`。
- 日志中的英文内部步骤和错误前缀；面向用户的提示才翻译。
- 设备型号名，例如 `iPhone 17 Pro Max`。
- 格式占位符 `%@`、`%lu`、`%lld`、`%llu`、`%o`、`errno` 和 `0x%llx`。

## 11. 验收标准

- 系统语言为简体中文时，根界面、文件浏览器、Apps、Cache Cleaner、Plist 编辑器、十六进制查看器、分享和主要错误提示均显示中文。
- 英文系统仍显示原有英文，不出现空文本、乱码或占位符丢失。
- 中文按钮不因过长截断；必要时只用更短译法（例如 `备份后清除`）。
- `./tests/run_all_tests.sh` 通过；如测试环境不支持 iOS 编译，会单独说明并至少运行可用的主机测试。
- 本地化资源被打进最终 IPA，而不只是留在源码目录。

## 附录 A. 补充：编辑器、提示与权限错误

| 原文（简体中文语言包键） | 建议中文 | 上下文 |
|---|---|---|
| `Save in progress` | `正在保存` | 文本/Plist/十六进制编辑器 |
| `Wait for the current save to finish before leaving or making more changes.` | `请等待当前保存完成后再离开或继续修改。` | 文本编辑器 |
| `Discard changes?` | `放弃更改？` | 未保存提示 |
| `Your text changes have not been saved.` | `你的文本更改尚未保存。` | 文本编辑器 |
| `Keep Editing` | `继续编辑` | 未保存提示 |
| `Cannot save` | `无法保存` | 文本编辑器 |
| `The file has no verified version snapshot. Reopen it before saving.` | `此文件没有已验证的版本快照，请重新打开后再保存。` | 文本编辑器 |
| `Not a valid property list` | `不是有效的属性列表` | 文本编辑器 |
| `Check the XML.` | `请检查 XML。` | 文本编辑器 |
| `Cannot encode` | `无法编码` | 文本编辑器 |
| `The text could not be encoded as UTF-8.` | `文本无法编码为 UTF-8。` | 文本编辑器 |
| `Save changes?` | `保存更改？` | 文本/Plist/十六进制编辑器 |
| `Save failed` | `保存失败` | 通用错误 |
| `Cannot open this item` | `无法打开此项目` | 文件打开失败 |
| `Nothing to select` | `没有可选择的项目` | 备份多选 |
| `Only complete backup folders can be selected here.` | `此处只能选择完整备份文件夹。` | 备份多选 |
| `Select Backups` | `选择备份` | 备份多选 |
| `Delete Backup…` | `删除备份…` | 文件菜单 |
| `Restore recovery` | `中断还原` | 启动还原提示 |
| `No App Group` | `缺少应用组` | 启动提示 |
| `This app needs an App Group to reach other folders. Re-sign it with a tool that keeps the App Group entitlement.` | `此 App 需要应用组才能访问其他文件夹。请使用保留应用组权限（entitlement）的工具重新签名。` | 启动提示 |
| `WQ Files by kolbicz` | `WQ Files，作者 kolbicz` | 关于区域 |
| `Sandbox escape: worse_query by @forcequitOS` | `沙盒逃逸：worse_query，作者 @forcequitOS` | 关于区域 |
| `On iOS 26, System Data and System Groups can't be reached (worse_query covers them on iOS 27 only), and Internal Daemons need a scan of every file id: the first one can take most of an hour on a well-used device, later ones only check new files.` | `在 iOS 26 上无法访问系统数据和系统组（worse_query 仅在 iOS 27 上覆盖它们），而内部守护进程需要扫描每个文件 ID：在频繁使用的设备上，首次扫描可能耗时将近一小时；后续扫描只检查新文件。` | 根界面说明 |
| `Overwritten and deleted files are copied to Backups first (also visible in the Files app). Long-press a backup to restore it.` | `被覆盖或删除的文件会先复制到“备份”（也可在“文件”App 中查看）。长按备份可将其还原。` | 根界面说明 |
| `Go to Path` | `前往路径` | 路径输入标题 |
| `\n… (only the beginning is shown)\n` | `\n…（仅显示开头部分）\n` | 文件预览截断说明 |
| `Cannot list this folder` | `无法列出此文件夹` | 列表错误 |
| `This file belongs to %@ (mode %o) and only its owner may %@ it. ` | `此文件属于 %@（模式 %o），只有所有者才能对其执行“%@”操作。` | 权限提示 |
| `Cannot inspect %@` | `无法检查 %@` | 备份/文件校验 |
| `Cannot encode %@` | `无法编码 %@` | 编码错误 |
| `Cannot inspect link %@` | `无法检查链接 %@` | 符号链接错误 |
| `the scan had limited access` | `扫描时访问受限` | 缓存清理原因 |
| `the crash-log target is not the expected canonical directory` | `崩溃日志目标不是预期的标准目录` | 缓存清理原因 |
| `the scanned cache targets are incomplete` | `扫描到的缓存目标不完整` | 缓存清理原因 |
| `the app container identity or ancestry is unavailable` | `App 容器标识或祖先路径不可用` | 缓存清理原因 |
| ` Close running apps first.` | ` 请先关闭正在运行的 App。` | 缓存清理说明（源码前导空格为键的一部分） |
| `WQ Files %@ (%@)\n%@\n\n%@` | `WQ Files %@（%@）\n%@\n\n%@` | 日志页标题区 |
| `0 KB` | `0 KB` | 大小显示 |
| `(empty)` | `（空）` | Plist 空值 |
| `Discard` | `放弃` | Plist/十六进制未保存提示 |
| `Name` | `名称` | 新建/重命名 |
| `Restore` | `还原备份` | App 备份确认按钮；单文件按钮见上方“还原文件” |
| `%@ · %@ · no identifier` | `%@ · %@ · 无标识符` | App 列表副标题 |
| `%@ · %@ · container identity unavailable` | `%@ · %@ · 容器标识不可用` | App 列表副标题 |
| `text` | `文本` | 十六进制文本搜索占位符 |

---

本文档随 `zh-Hans` 本地化一起提交；英文保留为 fallback，后续语言可继续新增 `.lproj`。
