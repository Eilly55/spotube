import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/components/Settings/About.dart';
import 'package:spotube/components/Settings/ColorSchemePickerDialog.dart';
import 'package:spotube/components/Shared/AdaptiveListTile.dart';
import 'package:spotube/components/Shared/PageWindowTitleBar.dart';
import 'package:spotube/hooks/useBreakpoints.dart';
import 'package:spotube/models/SpotifyMarkets.dart';
import 'package:spotube/models/SpotubeTrack.dart';
import 'package:spotube/provider/Auth.dart';
import 'package:spotube/provider/Playback.dart';
import 'package:spotube/provider/UserPreferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Settings extends HookConsumerWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final UserPreferences preferences = ref.watch(userPreferencesProvider);
    final Auth auth = ref.watch(authProvider);

    final pickColorScheme = useCallback((ColorSchemeType schemeType) {
      return () => showDialog(
          context: context,
          builder: (context) {
            return ColorSchemePickerDialog(
              schemeType: schemeType,
            );
          });
    }, []);

    final pickDownloadLocation = useCallback(() async {
      final dirStr = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Download Location",
      );
      if (dirStr == null) return;
      preferences.setDownloadLocation(dirStr);
    }, [preferences.downloadLocation]);

    var ytSearchFormatController = useTextEditingController(
      text: preferences.ytSearchFormat,
    );

    return SafeArea(
      child: Scaffold(
        appBar: PageWindowTitleBar(
          leading: const BackButton(),
          center: Text(
            "Settings",
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1366),
                child: ListView(
                  children: [
                    const Text(
                      " Account",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    if (auth.isAnonymous)
                      AdaptiveListTile(
                        leading: Icon(
                          Icons.login_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: AutoSizeText(
                          "Login with your Spotify account",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        trailing: (context, update) => ElevatedButton(
                          child: Text("Connect with Spotify".toUpperCase()),
                          onPressed: () {
                            GoRouter.of(context).push("/login");
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (auth.isLoggedIn)
                      Builder(builder: (context) {
                        Auth auth = ref.watch(authProvider);
                        return ListTile(
                          leading: const Icon(Icons.logout_rounded),
                          title: const AutoSizeText(
                            "Log out of this account",
                            maxLines: 1,
                          ),
                          trailing: ElevatedButton(
                            child: const Text("Logout"),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.red),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: Container(
                                    height: 200,
                                    width: 400,
                                    decoration: BoxDecoration(color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
                                    child: Column(
                                      children: [
                                        Expanded(child: Center(child: Text("Are you sure you want to log out?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(20)),
                                                child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: AutoSizeText("NO", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                                              ),
                                              SizedBox(width: 30),
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red)),
                                                child: TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(context).pop();
                                                      auth.logout();
                                                      GoRouter.of(context).pop();
                                                    },
                                                    child: AutoSizeText("YES", style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold))),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    const Text(
                      " Appearance",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    AdaptiveListTile(
                      leading: const Icon(Icons.dashboard_rounded),
                      title: const Text("Layout Mode"),
                      subtitle: const Text(
                        "Override responsive layout mode settings",
                      ),
                      trailing: (context, update) => DropdownButton<LayoutMode>(
                        value: preferences.layoutMode,
                        items: const [
                          DropdownMenuItem(
                            child: Text(
                              "Adaptive",
                            ),
                            value: LayoutMode.adaptive,
                          ),
                          DropdownMenuItem(
                            child: Text(
                              "Compact",
                            ),
                            value: LayoutMode.compact,
                          ),
                          DropdownMenuItem(
                            child: Text("Extended"),
                            value: LayoutMode.extended,
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            preferences.setLayoutMode(value);
                            update?.call(() {});
                          }
                        },
                      ),
                    ),
                    AdaptiveListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text("Theme"),
                      trailing: (context, update) => DropdownButton<ThemeMode>(
                        value: preferences.themeMode,
                        items: const [
                          DropdownMenuItem(
                            child: Text(
                              "Dark",
                            ),
                            value: ThemeMode.dark,
                          ),
                          DropdownMenuItem(
                            child: Text(
                              "Light",
                            ),
                            value: ThemeMode.light,
                          ),
                          DropdownMenuItem(
                            child: Text("System"),
                            value: ThemeMode.system,
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            preferences.setThemeMode(value);
                            update?.call(() {});
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text("Accent Color Scheme"),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      trailing: ColorTile(
                        color: preferences.accentColorScheme,
                        onPressed: pickColorScheme(ColorSchemeType.accent),
                        isActive: true,
                      ),
                      onTap: pickColorScheme(ColorSchemeType.accent),
                    ),
                    ListTile(
                      leading: const Icon(Icons.format_color_fill_rounded),
                      title: const Text("Background Color Scheme"),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      trailing: ColorTile(
                        color: preferences.backgroundColorScheme,
                        onPressed: pickColorScheme(ColorSchemeType.background),
                        isActive: true,
                      ),
                      onTap: pickColorScheme(ColorSchemeType.background),
                    ),
                    const Text(
                      " Playback",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    AdaptiveListTile(
                      leading: const Icon(Icons.multitrack_audio_rounded),
                      title: const Text("Audio Quality"),
                      trailing: (context, update) => DropdownButton<AudioQuality>(
                        value: preferences.audioQuality,
                        items: const [
                          DropdownMenuItem(
                            child: Text(
                              "High",
                            ),
                            value: AudioQuality.high,
                          ),
                          DropdownMenuItem(
                            child: Text("Low"),
                            value: AudioQuality.low,
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            preferences.setAudioQuality(value);
                            update?.call(() {});
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.fast_forward_rounded),
                      title: const Text(
                        "Skip non-music segments (SponsorBlock)",
                      ),
                      trailing: Switch.adaptive(
                        activeColor: Theme.of(context).primaryColor,
                        value: preferences.skipSponsorSegments,
                        onChanged: (state) {
                          preferences.setSkipSponsorSegments(state);
                        },
                      ),
                    ),
                    const Text(
                      " Search",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    AdaptiveListTile(
                      leading: const Icon(Icons.shopping_bag_rounded),
                      title: Text(
                        "Market Place",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      subtitle: Text(
                        "Recommendation Country",
                        style: Theme.of(context).textTheme.caption,
                      ),
                      trailing: (context, update) => ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: DropdownButton(
                          isExpanded: true,
                          value: preferences.recommendationMarket,
                          items: spotifyMarkets
                              .map(
                                (country) => (DropdownMenuItem(
                                  child: Text(country.last),
                                  value: country.first,
                                )),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            preferences.setRecommendationMarket(
                              value as String,
                            );
                            update?.call(() {});
                          },
                        ),
                      ),
                    ),
                    AdaptiveListTile(
                      leading: const Icon(Icons.screen_search_desktop_rounded),
                      title: const AutoSizeText(
                        "Format of the YouTube Search term",
                        maxLines: 2,
                      ),
                      subtitle: const Text("(Case sensitive)"),
                      breakOn: Breakpoints.lg,
                      trailing: (context, update) => ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: TextField(
                          controller: ytSearchFormatController,
                          decoration: InputDecoration(
                            isDense: true,
                            suffix: ElevatedButton(
                              child: const Icon(Icons.save_rounded),
                              onPressed: () {
                                preferences.setYtSearchFormat(
                                  ytSearchFormatController.value.text,
                                );
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            preferences.setYtSearchFormat(value);
                            update?.call(() {});
                          },
                        ),
                      ),
                    ),
                    AdaptiveListTile(
                      leading: const Icon(Icons.low_priority_rounded),
                      title: const AutoSizeText(
                        "Track Match Algorithm",
                        maxLines: 1,
                      ),
                      trailing: (context, update) => DropdownButton<SpotubeTrackMatchAlgorithm>(
                        value: preferences.trackMatchAlgorithm,
                        items: const [
                          DropdownMenuItem(
                            child: Text(
                              "Popular from Author",
                            ),
                            value: SpotubeTrackMatchAlgorithm.authenticPopular,
                          ),
                          DropdownMenuItem(
                            child: Text(
                              "Accurately Popular",
                            ),
                            value: SpotubeTrackMatchAlgorithm.popular,
                          ),
                          DropdownMenuItem(
                            child: Text("YouTube's choice is my choice"),
                            value: SpotubeTrackMatchAlgorithm.youtube,
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            preferences.setTrackMatchAlgorithm(value);
                            update?.call(() {});
                          }
                        },
                      ),
                    ),
                    const Text(
                      " Downloads",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    ListTile(
                      leading: const Icon(Icons.file_download_outlined),
                      title: const Text("Download Location"),
                      subtitle: Text(preferences.downloadLocation),
                      trailing: ElevatedButton(
                        child: const Icon(Icons.folder_rounded),
                        onPressed: pickDownloadLocation,
                      ),
                      onTap: pickDownloadLocation,
                    ),
                    ListTile(
                      leading: const Icon(Icons.lyrics_rounded),
                      title: const Text("Download lyrics along with the Track"),
                      trailing: Switch.adaptive(
                        activeColor: Theme.of(context).primaryColor,
                        value: preferences.saveTrackLyrics,
                        onChanged: (state) {
                          preferences.setSaveTrackLyrics(state);
                        },
                      ),
                    ),
                    const Text(
                      " About",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    AdaptiveListTile(
                      leading: const Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.pink,
                      ),
                      title: const AutoSizeText(
                        "We know you Love Spotube",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: (context, update) => ElevatedButton.icon(
                        icon: const Icon(Icons.favorite_outline_rounded),
                        label: const Text("Please Sponsor/Donate"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red[100],
                          onPrimary: Colors.pinkAccent,
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () {
                          launchUrlString(
                            "https://opencollective.com/spotube",
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.update_rounded),
                      title: const Text("Check for Update"),
                      trailing: Switch.adaptive(
                        activeColor: Theme.of(context).primaryColor,
                        value: preferences.checkUpdate,
                        onChanged: (checked) => preferences.setCheckUpdate(checked),
                      ),
                    ),
                    const About()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
