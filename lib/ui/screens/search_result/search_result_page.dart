import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tipitaka_pali/business_logic/models/index.dart';
import 'package:tipitaka_pali/business_logic/models/search_result.dart';
import 'package:tipitaka_pali/ui/screens/home/widgets/search_result_list_tile.dart';
import 'package:tipitaka_pali/ui/screens/search_result/search_result_provider.dart';
import 'package:tipitaka_pali/ui/widgets/loading_view.dart';
import 'search_filter_provider.dart';
import 'search_filter_view.dart';

class SearchResultPage extends StatelessWidget {
  final String searchWord;
  //  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  SearchResultPage({
    Key? key,
    required this.searchWord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<SearchFilterController>(
              create: (_) => SearchFilterController()),
          ChangeNotifierProxyProvider<SearchFilterController,
                  SearchResultController>(
              create: (_) => SearchResultController(
                  searchWord: searchWord,
                  filterController: SearchFilterController()),
              update: (_, filterController, resultConroller) {
                resultConroller!.onChangeFilter(filterController);
                return resultConroller;
              }),
        ],
        builder: (context, _) {
          // final notifier = context.watch<SearchResultNotifier>();
          final state = context.watch<SearchResultController>().state;

          return state.when(
            loading: () => LoadingView(),
            noData: () => NoDataView(searchWord: searchWord),
            loaded: (results, bookCount) => DataView(
              searchWord: searchWord,
              results: results,
              bookCount: bookCount,
            ),
          );
        });
  }
}

class NoDataView extends StatelessWidget {
  const NoDataView({Key? key, required this.searchWord}) : super(key: key);
  final String searchWord;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Cannot find $searchWord.')),
    );
  }
}

class DataView extends StatelessWidget {
  const DataView(
      {Key? key,
      required this.searchWord,
      required this.results,
      required this.bookCount})
      : super(key: key);
  final String searchWord;
  final List<Index> results;
  final int bookCount;

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<SearchResultController>();

    return Scaffold(
      // key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Found ${results.length} in $bookCount books'),
        actions: [
          // add builder to call method of Scaffold.of(context)
          // Builder(
          //     builder: (context) => IconButton(
          //         onPressed: () {
          //           Scaffold.of(context)
          //               .showBottomSheet((_) => SearchFilterView());
          //         },
          //         icon: Icon(Icons.filter_list))),
        ],
      ),
      body: Stack(
        children: [
          results.isEmpty ?
          Center(child: Text('Not any more exist in other books'),) :
          ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final Index index = results[i];
                return _buildResultListItem(index: index, notifier: notifier);
              }),
          Positioned(
            bottom: 16,
            right: 16,
              child: Builder(
                builder: (context) {
                  return FloatingActionButton.extended(
            onPressed: () => Scaffold.of(context).showBottomSheet((context) => SearchFilterView()),
            label: Text('Filter'),
            icon: Icon(Icons.filter_list),
          );
                }
              ))
        ],
      ),
    );
  }

  Widget _buildResultListItem(
      {required Index index, required SearchResultController notifier}) {
    return FutureBuilder(
      future: notifier.getDetailResult(index),
      builder: (BuildContext context, AsyncSnapshot<SearchResult> snapshot) {
        if (snapshot.hasData) {
          final result = snapshot.data!;
          return GestureDetector(
            child: SearchResultListTile(
              result: result,
              textToHighlight: searchWord,
            ),
            onTap: () {
              notifier.openBook(result, context);
            },
          );
        }
        return LoadingView();
      },
    );
  }
}