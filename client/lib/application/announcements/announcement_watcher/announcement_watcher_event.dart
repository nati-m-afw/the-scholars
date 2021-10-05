part of 'announcement_watcher_bloc.dart';

@freezed
abstract class AnnouncementWatcherEvent with _$AnnouncementWatcherEvent {
  const factory AnnouncementWatcherEvent.getAllStarted() = _GetAllStarted;
  const factory AnnouncementWatcherEvent.announcementsReceived(
          Either<AnnouncementFailure, List<Announcement>> failureOrSuccess) =
      _AnnouncementsReceived;
}
