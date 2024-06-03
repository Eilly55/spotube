part of '../spotify.dart';

final artistIsFollowingProvider = FutureProvider.family(
  (ref, String artistId) async {
    final spotify = ref.watch(spotifyProvider);
    return spotify.me.checkFollowing(FollowingType.artist, [artistId]).then(
      (value) => value[artistId] ?? false,
    );
  },
);
