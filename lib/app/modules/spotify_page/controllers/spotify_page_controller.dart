import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:playlist_music/utils/print_util.dart';
import 'package:just_audio/just_audio.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String imageUrl;
  final String previewUrl;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.previewUrl,
  });
}

class SpotifyController extends GetxController {
  var isLoading = false.obs;
  var songs = <SongModel>[].obs;

  final AudioPlayer audioPlayer = AudioPlayer();
  var isPlaying = false.obs;
  var currentTrackId = "".obs;
  var currentArtist = "".obs;
  var currentImageUrl = "".obs;
  var currentImageTitle = "".obs;
  var currentMusicCompleted = ''.obs;
  var currentMusicUrl = ''.obs;
  var currentPosition = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    searchTracks(_getRandomKeyword());

    audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
    });

    audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    });

    audioPlayer.playerStateStream.listen((playerState) {
      isPlaying.value = playerState.playing;
      if (playerState.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        isPlaying.refresh();
        currentMusicCompleted.value = currentTrackId.value;
      }
    });
  }

  String _getRandomKeyword() {
    final keywords = [
      'top',
      'hits',
      'love',
      'pop',
      'rock',
      'ed sheeran',
      'taylor swift',
    ];
    keywords.shuffle();
    return keywords.first;
  }

  Future<void> searchTracks(String keyword) async {
    if (keyword.isEmpty) {
      keyword = _getRandomKeyword();
    }
    isLoading.value = true;
    final url = 'https://api.deezer.com/search?q=$keyword&type=track&limit=10';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['data'] as List;
      printFullJson(items[0]);
      songs.value =
          items
              .map(
                (e) => SongModel(
                  id: "${e['id']}",
                  title: e['title'],
                  artist: e['artist']['name'],
                  imageUrl: e['album']['cover_big'],
                  previewUrl: e['preview'] ?? '',
                ),
              )
              .toList();
    } else {
      print('Failed to fetch songs');
    }

    isLoading.value = false;
  }

  Future<void> playPause(
    String previewUrl,
    String title,
    String artist,
    String imageUrl,
    String id,
  ) async {
    if (currentMusicCompleted.value == id.toString()) {
      print("=====> เล่นเพลงซ้ำ");
      try {
        isPlaying.value = true;
        await audioPlayer.stop();
        currentTrackId.value = id;
        currentArtist.value = artist;
        currentImageUrl.value = imageUrl;
        currentImageTitle.value = title;
        await audioPlayer.setUrl(previewUrl);
        await audioPlayer.play();
      } catch (e) {
        Get.snackbar(
          'เกิดข้อผิดพลาด',
          'ไม่สามารถเล่นเพลงได้',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    if (previewUrl.isEmpty) {
      Get.snackbar(
        'ไม่สามารถเล่นเพลงได้',
        'ไม่พบลิงก์ตัวอย่างเพลง',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (currentTrackId.value == id) {
      if (isPlaying.value) {
        isPlaying.value = false;
        print("=====> กำลังเล่นอยู่ -> หยุดเล่น");
        await audioPlayer.pause();
      } else {
        print("=====> หยุดอยู่หรือเล่นจบแล้ว -> เล่นต่อ");
        isPlaying.value = true;
        await audioPlayer.play();
      }
    }
    // กรณีเลือกเพลงใหม่
    else {
      print("=====> เล่นเพลงใหม่");
      try {
        isPlaying.value = true;
        await audioPlayer.stop();
        currentTrackId.value = id;
        currentArtist.value = artist;
        currentImageUrl.value = imageUrl;
        currentImageTitle.value = title;
        currentMusicCompleted.value = "";
        currentMusicUrl.value = previewUrl;
        await audioPlayer.setUrl(previewUrl);
        await audioPlayer.play();
      } catch (e) {
        print("Error playing audio: $e");
        Get.snackbar(
          'เกิดข้อผิดพลาด',
          'ไม่สามารถเล่นเพลงได้',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (currentTrackId.value.isEmpty) return;
    if (currentTrackId.value == currentMusicCompleted.value) {
      try {
        isPlaying.value = true;
        await audioPlayer.stop();
        currentTrackId.value = currentTrackId.value;
        await audioPlayer.setUrl(currentMusicUrl.value);
        await audioPlayer.play();
      } catch (e) {
        Get.snackbar(
          'เกิดข้อผิดพลาด',
          'ไม่สามารถเล่นเพลงได้',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }
    if (isPlaying.value) {
      audioPlayer.pause();
      isPlaying.value = false;
    } else {
      audioPlayer.play();
      isPlaying.value = true;
    }
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
