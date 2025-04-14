import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/spotify_page_controller.dart';

class SpotifyPageView extends StatelessWidget {
  final SpotifyController ctrl = Get.put(SpotifyController());
  final TextEditingController searchCtrl = TextEditingController();

  SpotifyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: TextField(
              controller: searchCtrl,
              onSubmitted: (val) => ctrl.searchTracks(val),
              decoration: InputDecoration(
                hintText: 'ค้นหาเพลง...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => ctrl.searchTracks(searchCtrl.text),
                ),
              ),
            ),
          ),
          Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ctrl.songs.isEmpty) {
              return const Expanded(child: Center(child: Text('ไม่พบเพลง')));
            }

            return Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: ctrl.songs.length,
                itemBuilder: (_, index) {
                  final song = ctrl.songs[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80.w,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFD700),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              bottomLeft: Radius.circular(12.r),
                            ),
                          ),
                          child:
                              song.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.r),
                                      bottomLeft: Radius.circular(12.r),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: song.imageUrl,
                                      fit: BoxFit.cover,
                                      height: 80.h,
                                      width: 80.w,
                                      placeholder:
                                          (context, url) => Center(
                                            child: Icon(
                                              Icons.headphones,
                                              color: Colors.black87,
                                              size: 36.sp,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Center(
                                            child: Icon(
                                              Icons.headphones,
                                              color: Colors.black87,
                                              size: 36.sp,
                                            ),
                                          ),
                                    ),
                                  )
                                  : Center(
                                    child: Icon(
                                      Icons.headphones,
                                      color: Colors.black87,
                                      size: 36.sp,
                                    ),
                                  ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  song.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  song.artist,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Obx(
                          () => Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: IconButton(
                              icon: Icon(
                                (ctrl.isPlaying.value &&
                                        ctrl.currentTrackId.value == song.id)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 30.sp,
                                color: Colors.black87,
                              ),
                              onPressed:
                                  () => ctrl.playPause(
                                    song.previewUrl,
                                    song.title,
                                    song.artist,
                                    song.imageUrl,
                                    song.id,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
          Obx(() {
            if (ctrl.currentTrackId.value.isEmpty) {
              return SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              height: 150.h,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      children: [
                        Obx(
                          () => SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Color(0xFFFFD700),
                              inactiveTrackColor: Colors.grey[300],
                              trackHeight: 4,
                              thumbColor: Color(0xFFFFD700),
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: 8.r,
                              ),
                              overlayColor: Color(0xFFFFD700).withAlpha(32),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: 14.r,
                              ),
                            ),
                            child: Slider(
                              min: 0,
                              max:
                                  ctrl.totalDuration.value.inMilliseconds
                                              .toDouble() >
                                          0
                                      ? ctrl.totalDuration.value.inMilliseconds
                                          .toDouble()
                                      : 1,
                              value: ctrl.currentPosition.value.inMilliseconds
                                  .toDouble()
                                  .clamp(
                                    0,
                                    ctrl.totalDuration.value.inMilliseconds
                                                .toDouble() >
                                            0
                                        ? ctrl
                                            .totalDuration
                                            .value
                                            .inMilliseconds
                                            .toDouble()
                                        : 1,
                                  ),
                              onChanged: (value) {
                                ctrl.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                () => Text(
                                  ctrl.formatDuration(
                                    ctrl.currentPosition.value,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Obx(
                                () => Text(
                                  ctrl.formatDuration(ctrl.totalDuration.value),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h,),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 16.w),
                        child: Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child:
                              ctrl.currentImageUrl.value.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: CachedNetworkImage(
                                      imageUrl: ctrl.currentImageUrl.value,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (context, url, error) => Center(
                                            child: Icon(
                                              Icons.headphones,
                                              color: Colors.black87,
                                              size: 30.sp,
                                            ),
                                          ),
                                    ),
                                  )
                                  : Center(
                                    child: Icon(
                                      Icons.headphones,
                                      color: Colors.black87,
                                      size: 30.sp,
                                    ),
                                  ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ctrl.currentImageTitle.value,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                ctrl.currentArtist.value,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          ctrl.isPlaying.value ? Icons.pause : Icons.play_arrow,
                          size: 36.sp,
                          color: Colors.black87,
                        ),
                        onPressed: () => ctrl.togglePlayPause(),
                      ),

                      SizedBox(width: 16.w),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
