import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/models/local_track.dart';
import 'package:spotube/provider/audio_player/audio_player.dart';
import 'package:spotube/services/audio_player/audio_player.dart';
import 'package:spotube/services/sourced_track/sourced_track.dart';

final sourcedTrackProvider =
    FutureProvider.family<SourcedTrack?, SpotubeMedia?>((ref, media) async {
  final track = media?.track;
  if (track == null || track is LocalTrack) {
    return null;
  }

  ref.listen(
    audioPlayerProvider.select((value) => value.tracks),
    (old, next) {
      if (next.isEmpty || next.none((element) => element.id == track.id)) {
        ref.invalidateSelf();
      }
    },
  );

  final sourcedTrack = media?.extras?["switch"] == true
      ? await SourcedTrack.fetchFromTrackAltSource(track: track, ref: ref)
      : await SourcedTrack.fetchFromTrack(track: track, ref: ref);

  return sourcedTrack;
});
