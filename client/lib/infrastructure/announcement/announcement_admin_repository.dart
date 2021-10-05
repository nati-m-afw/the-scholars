import 'dart:convert';

import 'package:client/domain/announcement/announcement_failure.dart';
import 'package:client/domain/announcement/announcement.dart';
import 'package:client/domain/announcement/i_admin_announcement_repository.dart';
import 'package:client/domain/announcement/value_objects.dart';
import 'package:client/infrastructure/announcement/announcement_dto.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rxdart/rxdart.dart';

@LazySingleton(as: IAnnouncementRepository)
class AnnoncementRepository implements IAnnouncementRepository {
  http.Client? client = http.Client();
  // static const String _baseUrl = "http://192.168.0.147:5000/admin";

  // static const String _baseUrl = "http://localhost:3000/admin";

  // static const String _baseUrl = "http://10.0.2.2:5000/admin";

  static final String _baseUrl = "${dotenv.env["API"]}/admin";

  AnnoncementRepository();
  @override
  Stream<Either<AnnouncementFailure, List<Announcement>>>
      getAnnouncements() {
    final Uri url = Uri.parse("ws://localhost:3000/admin/stream/announcements");
    final List<Announcement> announcements = [];

    try {
      final channel = WebSocketChannel.connect(url);
      
      return channel.stream.flatMap((event) {
        final List announcementsJson = jsonDecode(event as String) as List;

        for (final announcementJson in announcementsJson) {
          final Announcement announcement =
              AnnouncementDto.fromJson(announcementJson as Map<String, dynamic>)
                  .toDomain();
          announcements.add(announcement);
        }

        final Iterable<Either<AnnouncementFailure, List<Announcement>>> i = [right(announcements)];

        return Stream.fromIterable(i);
      });
    } catch (e) {
      // yield left(const AnnouncementFailure.networkError());
      // return
      throw Exception();
    }
  }

  @override
  Future<Either<AnnouncementFailure, Announcement>> saveAnnouncement(
      Announcement announcement) async {
    final AnnouncementDto announcementDto =
        AnnouncementDto.fromDomain(announcement);
    final Uri url = Uri.parse("$_baseUrl/announcements");
    final outgoingJson = announcementDto.toJson();

    try {
      final response = await client!.post(url, body: outgoingJson);

      if (response.statusCode == 201) {
        final idMap = jsonDecode(response.body) as Map;
        return right(
            announcement.copyWith(id: AnnouncementId(idMap["announcementId"] as String)));
      } else {
        return left(const AnnouncementFailure.serverError());
      }
    } catch (e) {
      return left(const AnnouncementFailure.networkError());
    }
  }

  @override
  Future<Either<AnnouncementFailure, Unit>> deleteAnnouncement(
      Announcement announcement) async {
    final AnnouncementDto announcementDto =
        AnnouncementDto.fromDomain(announcement);
    final Uri url = Uri.parse("$_baseUrl/announcements/${announcementDto.id}");
    final outgoingJson = announcementDto.toJson();

    try {
      final response = await client!.delete(url, body: outgoingJson);

      if (response.statusCode == 204) {
        return right(unit);
      } else {
        return left(const AnnouncementFailure.serverError());
      }
    } catch (e) {
      return left(const AnnouncementFailure.networkError());
    }
  }
}
