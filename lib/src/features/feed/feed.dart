import 'package:donation/src/common_widgets/customLoader.dart';
import 'package:donation/src/common_widgets/emptyList.dart';
import 'package:donation/src/features/feed/controller/feed_controller.dart';
import 'package:donation/src/features/feed/post.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var streamAsyncValue = ref.watch(postDataProvider);
    return CustomScrollView(
      slivers: <Widget>[
        streamAsyncValue.when(
          data: (savedData) {
            final results = savedData.results;
            if (results.isEmpty) {
              return SliverToBoxAdapter(
                child: EmptyList(
                  'No Post added yet',
                  subTitle:
                      'When new Post added, they\'ll show up here \n Tap post button to add new',
                ),
              );
            } else {
              return SliverList(
                delegate: SliverChildListDelegate(
                  results.map(
                    (post) {
                      return Container(
                        color: Colors.white,
                        child: PostItem(
                          model: post,
                          scaffoldKey: scaffoldKey,
                        ),
                      );
                    },
                  ).toList(),
                ),
              );
            }
          },
          error: (Object error, StackTrace stackTrace) {
            return Text(error.toString());
          },
          loading: () {
            return SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 135,
                child: CustomScreenLoader(
                  height: double.infinity,
                  width: double.infinity,
                  backgroundColor: Colors.white,
                ),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Container(height: 80),
        )
      ],
    );
  }
}
