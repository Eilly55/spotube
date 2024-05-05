import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart' hide Search;
import 'package:spotube/models/spotify/recommendation_seeds.dart';
import 'package:spotube/pages/album/album.dart';
import 'package:spotube/pages/connect/connect.dart';
import 'package:spotube/pages/connect/control/control.dart';
import 'package:spotube/pages/getting_started/getting_started.dart';
import 'package:spotube/pages/home/feed/feed_section.dart';
import 'package:spotube/pages/home/genres/genre_playlists.dart';
import 'package:spotube/pages/home/genres/genres.dart';
import 'package:spotube/pages/home/home.dart';
import 'package:spotube/pages/lastfm_login/lastfm_login.dart';
import 'package:spotube/pages/library/playlist_generate/playlist_generate.dart';
import 'package:spotube/pages/library/playlist_generate/playlist_generate_result.dart';
import 'package:spotube/pages/lyrics/mini_lyrics.dart';
import 'package:spotube/pages/playlist/liked_playlist.dart';
import 'package:spotube/pages/playlist/playlist.dart';
import 'package:spotube/pages/profile/profile.dart';
import 'package:spotube/pages/search/search.dart';
import 'package:spotube/pages/settings/blacklist.dart';
import 'package:spotube/pages/settings/about.dart';
import 'package:spotube/pages/settings/logs.dart';
import 'package:spotube/pages/track/track.dart';
import 'package:spotube/provider/authentication_provider.dart';
import 'package:spotube/services/kv_store/kv_store.dart';
import 'package:spotube/utils/platform.dart';
import 'package:spotube/components/shared/spotube_page_route.dart';
import 'package:spotube/pages/artist/artist.dart';
import 'package:spotube/pages/library/library.dart';
import 'package:spotube/pages/desktop_login/login_tutorial.dart';
import 'package:spotube/pages/desktop_login/desktop_login.dart';
import 'package:spotube/pages/lyrics/lyrics.dart';
import 'package:spotube/pages/root/root_app.dart';
import 'package:spotube/pages/settings/settings.dart';
import 'package:spotube/pages/settings/library.dart';
import 'package:spotube/pages/mobile_login/mobile_login.dart';

final rootNavigatorKey = Catcher2.navigatorKey;
final shellRouteNavigatorKey = GlobalKey<NavigatorState>();
final routerProvider = Provider((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: shellRouteNavigatorKey,
        builder: (context, state, child) => RootApp(child: child),
        routes: [
          GoRoute(
            path: "/",
            redirect: (context, state) async {
              final authNotifier = ref.read(authenticationProvider.notifier);
              final json = await authNotifier.box.get(authNotifier.cacheKey);

              if (json?["cookie"] == null &&
                  !KVStoreService.doneGettingStarted) {
                return "/getting-started";
              }

              return null;
            },
            pageBuilder: (context, state) =>
                const SpotubePage(child: HomePage()),
            routes: [
              GoRoute(
                path: "genres",
                pageBuilder: (context, state) =>
                    const SpotubePage(child: GenrePage()),
              ),
              GoRoute(
                path: "genre/:categoryId",
                pageBuilder: (context, state) => SpotubePage(
                  child: GenrePlaylistsPage(
                    category: state.extra as Category,
                  ),
                ),
              ),
              GoRoute(
                path: "feeds/:feedId",
                pageBuilder: (context, state) => SpotubePage(
                  child: HomeFeedSectionPage(
                    sectionUri: state.pathParameters["feedId"] as String,
                  ),
                ),
              )
            ],
          ),
          GoRoute(
            path: "/search",
            name: "Search",
            pageBuilder: (context, state) =>
                const SpotubePage(child: SearchPage()),
          ),
          GoRoute(
              path: "/library",
              name: "Library",
              pageBuilder: (context, state) =>
                  const SpotubePage(child: LibraryPage()),
              routes: [
                GoRoute(
                    path: "generate",
                    pageBuilder: (context, state) =>
                        const SpotubePage(child: PlaylistGeneratorPage()),
                    routes: [
                      GoRoute(
                        path: "result",
                        pageBuilder: (context, state) => SpotubePage(
                          child: PlaylistGenerateResultPage(
                            state: state.extra as GeneratePlaylistProviderInput,
                          ),
                        ),
                      ),
                    ]),
              ]),
          GoRoute(
            path: "/lyrics",
            name: "Lyrics",
            pageBuilder: (context, state) =>
                const SpotubePage(child: LyricsPage()),
          ),
          GoRoute(
            path: "/settings",
            pageBuilder: (context, state) => const SpotubePage(
              child: SettingsPage(),
            ),
            routes: [
              GoRoute(
                path: "blacklist",
                pageBuilder: (context, state) => SpotubeSlidePage(
                  child: const BlackListPage(),
                ),
              ),
              GoRoute(
                path: "local_library",
                pageBuilder: (context, state) => SpotubeSlidePage(
                  child: const LocalLibrariesPage(),
                ),
              ),
              if (!kIsWeb)
                GoRoute(
                  path: "logs",
                  pageBuilder: (context, state) => SpotubeSlidePage(
                    child: const LogsPage(),
                  ),
                ),
              GoRoute(
                path: "about",
                pageBuilder: (context, state) => SpotubeSlidePage(
                  child: const AboutSpotube(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: "/album/:id",
            pageBuilder: (context, state) {
              assert(state.extra is AlbumSimple);
              return SpotubePage(
                child: AlbumPage(album: state.extra as AlbumSimple),
              );
            },
          ),
          GoRoute(
            path: "/artist/:id",
            pageBuilder: (context, state) {
              assert(state.pathParameters["id"] != null);
              return SpotubePage(
                  child: ArtistPage(state.pathParameters["id"]!));
            },
          ),
          GoRoute(
            path: "/playlist/:id",
            pageBuilder: (context, state) {
              assert(state.extra is PlaylistSimple);
              return SpotubePage(
                child: state.pathParameters["id"] == "user-liked-tracks"
                    ? LikedPlaylistPage(playlist: state.extra as PlaylistSimple)
                    : PlaylistPage(playlist: state.extra as PlaylistSimple),
              );
            },
          ),
          GoRoute(
            path: "/track/:id",
            pageBuilder: (context, state) {
              final id = state.pathParameters["id"]!;
              return SpotubePage(
                child: TrackPage(trackId: id),
              );
            },
          ),
          GoRoute(
            path: "/connect",
            pageBuilder: (context, state) => const SpotubePage(
              child: ConnectPage(),
            ),
            routes: [
              GoRoute(
                path: "control",
                pageBuilder: (context, state) {
                  return const SpotubePage(
                    child: ConnectControlPage(),
                  );
                },
              )
            ],
          ),
          GoRoute(
            path: "/profile",
            pageBuilder: (context, state) =>
                const SpotubePage(child: ProfilePage()),
          )
        ],
      ),
      GoRoute(
        path: "/mini-player",
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => SpotubePage(
          child: MiniLyricsPage(prevSize: state.extra as Size),
        ),
      ),
      GoRoute(
        path: "/getting-started",
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const SpotubePage(
          child: GettingStarting(),
        ),
      ),
      GoRoute(
        path: "/login",
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => SpotubePage(
          child: kIsMobile ? const WebViewLogin() : const DesktopLoginPage(),
        ),
      ),
      GoRoute(
        path: "/login-tutorial",
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const SpotubePage(
          child: LoginTutorial(),
        ),
      ),
      GoRoute(
        path: "/lastfm-login",
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            const SpotubePage(child: LastFMLoginPage()),
      ),
    ],
  );
});
