import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:client/domain/announcement/announcement.dart';
import 'package:client/domain/announcement/announcement_failure.dart';
import 'package:client/domain/announcement/i_admin_announcement_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'announcement_watcher_event.dart';
part 'announcement_watcher_state.dart';

part 'announcement_watcher_bloc.freezed.dart';

@injectable
class AnnouncementWatcherBloc
    extends Bloc<AnnouncementWatcherEvent, AnnouncementWatcherState> {
  final IAnnouncementRepository _iAnnouncementRepository;

  AnnouncementWatcherBloc(this._iAnnouncementRepository)
      : super(const AnnouncementWatcherState.initial());

  @override
  Stream<AnnouncementWatcherState> mapEventToState(
    AnnouncementWatcherEvent event,
  ) async* {
    yield* event.map(getAllStarted: (e) async* {
      yield const AnnouncementWatcherState.loadInProgress();
      _iAnnouncementRepository.getAnnouncements().listen((failureOrSuccess) =>
          add(AnnouncementWatcherEvent.announcementsReceived(
              failureOrSuccess)));
      // yield* _iAnnouncementRepository.getAnnouncements().map(
      //     (failureOrSuccess) => failureOrSuccess.fold(
      //         (l) => AnnouncementWatcherState.loadFailure(l),
      //         (announcements) =>
      //             AnnouncementWatcherState.loadSuccess(announcements)));

      // return stream.flatMap((value) {
      //   final Iterable<AnnouncementWatcherState> i = [
      //     value.fold(
      //         (l) => AnnouncementWatcherState.loadFailure(l),
      //         (announcements) =>
      //             AnnouncementWatcherState.loadSuccess(announcements))
      //   ];

      //   return Stream.fromIterable(i);
      // });
      // await for (final failureOrSuccess in stream) {
      //   yield failureOrSuccess.fold(
      //       (l) => AnnouncementWatcherState.loadFailure(l),
      //       (announcements) =>
      //           AnnouncementWatcherState.loadSuccess(announcements));
      // }
    }, announcementsReceived: (e) async* {
      yield const AnnouncementWatcherState.dataChange();
      yield e.failureOrSuccess.fold(
          (l) => AnnouncementWatcherState.loadFailure(l),
          (announcements) =>
              AnnouncementWatcherState.loadSuccess(announcements));
    });
  }
}
