import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/components/album/album_card.dart';
import 'package:spotube/components/shared/shimmers/shimmer_playbutton_card.dart';
import 'package:spotube/components/shared/fallbacks/anonymous_fallback.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/hooks/use_breakpoint_value.dart';
import 'package:spotube/provider/authentication_provider.dart';
import 'package:spotube/services/queries/queries.dart';

import 'package:spotube/utils/type_conversion_utils.dart';

class UserAlbums extends HookConsumerWidget {
  const UserAlbums({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final auth = ref.watch(AuthenticationNotifier.provider);
    final albumsQuery = useQueries.album.ofMine(ref);

    final spacing = useBreakpointValue<double>(
      xs: 0,
      sm: 0,
      others: 20,
    );

    final searchText = useState('');

    final albums = useMemoized(() {
      if (searchText.value.isEmpty) {
        return albumsQuery.data?.toList() ?? [];
      }
      return albumsQuery.data
              ?.map((e) => (
                    weightedRatio(e.name!, searchText.value),
                    e,
                  ))
              .sorted((a, b) => b.$1.compareTo(a.$1))
              .where((e) => e.$1 > 50)
              .map((e) => e.$2)
              .toList() ??
          [];
    }, [albumsQuery.data, searchText.value]);

    if (auth == null) {
      return const AnonymousFallback();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await albumsQuery.refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  onChanged: (value) => searchText.value = value,
                  leading: const Icon(SpotubeIcons.filter),
                  hintText: context.l10n.filter_albums,
                ),
                const SizedBox(height: 20),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(16.0),
                    child: const ShimmerPlaybuttonCard(count: 7),
                  ),
                  secondChild: Wrap(
                    spacing: spacing, // gap between adjacent chips
                    runSpacing: 20, // gap between lines
                    alignment: WrapAlignment.center,
                    children: albums
                        .map((album) => AlbumCard(
                              TypeConversionUtils.simpleAlbum_X_Album(album),
                            ))
                        .toList(),
                  ),
                  crossFadeState: albumsQuery.isLoading ||
                          !albumsQuery.hasData ||
                          searchText.value.isNotEmpty
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
