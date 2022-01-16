class File
{
  File({required this.name,
        required this.path,
        required this.parentFolderPath,
        required this.parentFolder,
        required this.type,
        required this.yandexUserId,
        required this.resourceId,
        required this.synchronizationProcessId,
        required this.createDateTime,
        required this.lastUpdateDateTime});
  final String name;
  final String path;
  final String parentFolderPath;
  final String parentFolder;
  final String type;
  final String yandexUserId;
  final String? resourceId;
  final String synchronizationProcessId;
  final String createDateTime;
  final String? lastUpdateDateTime;
}