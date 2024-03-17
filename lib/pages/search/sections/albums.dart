import 'package:flutter/material.dart' hide Page;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:spotify/spotify.dart';
import 'package:spotube/components/shared/horizontal_playbutton_card_view/horizontal_playbutton_card_view.dart';
import 'package:spotube/extensions/context.dart';
import 'package:spotube/provider/spotify/spotify.dart';
import 'package:spotube/utils/type_conversion_utils.dart';

class SearchAlbumsSection extends HookConsumerWidget {
  const SearchAlbumsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final query = ref.watch(searchProvider(SearchType.album));
    final notifier = ref.watch(searchProvider(SearchType.album).notifier);
    final albums = useMemoized(
      () =>
          query.value?.items
              .cast<AlbumSimple>()
              .map(TypeConversionUtils.simpleAlbum_X_Album)
              .toList() ??
          [],
      [query.value],
    );

    return HorizontalPlaybuttonCardView(
      isLoadingNextPage: query.isLoadingNextPage,
      hasNextPage: query.value?.hasMore == true,
      items: albums,
      onFetchMore: notifier.fetchMore,
      title: Text(context.l10n.albums),
    );
  }
}
