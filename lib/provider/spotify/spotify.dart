library spotify;

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:spotify/spotify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:riverpod/src/async_notifier.dart';
import 'package:spotube/extensions/map.dart';
import 'package:spotube/models/lyrics.dart';
import 'package:spotube/models/spotify/recommendation_seeds.dart';
import 'package:spotube/models/spotify_friends.dart';
import 'package:spotube/provider/custom_spotify_endpoint_provider.dart';
import 'package:spotube/provider/spotify_provider.dart';
import 'package:spotube/provider/user_preferences/user_preferences_provider.dart';
import 'package:spotube/utils/persisted_state_notifier.dart';
import 'package:http/http.dart' as http;

part 'album/favorite.dart';
part 'album/tracks.dart';
part 'album/releases.dart';
part 'album/is_saved.dart';

part 'artist/artist.dart';
part 'artist/is_following.dart';
part 'artist/following.dart';
part 'artist/top_tracks.dart';
part 'artist/albums.dart';

part 'category/genres.dart';
part 'category/categories.dart';
part 'category/playlists.dart';

part 'lyrics/synced.dart';

part 'playlist/favorite.dart';
part 'playlist/playlist.dart';
part 'playlist/liked.dart';
part 'playlist/tracks.dart';
part 'playlist/featured.dart';
part 'playlist/generate.dart';

part 'search/search.dart';

part 'user/me.dart';
part 'user/friends.dart';

part 'tracks/track.dart';

part 'views/view.dart';

part 'utils/mixin.dart';
part 'utils/state.dart';
part 'utils/provider.dart';
part 'utils/persistence.dart';
