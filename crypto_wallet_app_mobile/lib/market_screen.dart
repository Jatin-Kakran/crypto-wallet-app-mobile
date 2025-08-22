//import 'package:core_wallet/utils/bottom_nav_bar.dart';
// import 'package:core_wallet/constants/app_sizes.dart';
// import 'package:core_wallet/widgets/clickable_walletname.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../constants/app_colors.dart';
// import '../constants/app_sizes.dart';
// import '../new_wallet_create.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 1;
  String? walletName = "Unnamed Wallet";

  final List<Map<String, dynamic>> filters = [
    // {'title': 'Watchlist'},
    {'title': 'All', 'change': '-4.16%'},
    {'title': 'Hot'},
    {'title': 'New'},
    {'title': 'Gainers'},
    // {'title': 'Losers'},
    // {'title': 'Liquid Staking', 'change': '+0.03%'},
    // {'title': 'CeFi', 'change': '-1.86%'},
    // {'title': 'PoW', 'change': '-2.22%'},
    // {'title': ''}, // Empty icon filter
  ];

  List<String> tabTitles = ["Coin", "NFT", "News"];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  Future<void> loadWalletName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      walletName = prefs.getString("wallet_name") ?? "Unnamed Wallet";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    //final iconColor = AppColors.iconColor;
    //final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    // final scaleFactor = (screenWidth + screenHeight);
    // final iconScale = AppSizes.iconSize(context);
    // final textScale = AppSizes.textSize(context);
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   title: ClickableWalletName(),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.search_outlined, color: Colors.white),
      //       onPressed: () {},
      //     ),
      //   ],
      //   bottom: PreferredSize(
      //     preferredSize: Size.fromHeight(40),
      //     child: Align(
      //       alignment: Alignment.centerLeft, // or center
      //       child: TabBar(
      //         controller: _tabController,
      //         //isScrollable: true,
      //         labelColor: Colors.white,
      //         labelStyle: TextStyle(fontSize: AppSizes.textSize(context) * 1.3),
      //         unselectedLabelColor: Colors.grey,
      //         indicatorColor: Colors.deepPurpleAccent,
      //         labelPadding: EdgeInsets.symmetric(horizontal: 12),
      //         tabs: List.generate(tabTitles.length, (index) {
      //           return Tab(text: tabTitles[index]);
      //         }),
      //       ),
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController, // ✅ connect controller
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      _buildFilterGrid(screenWidth, isPortrait),
                    ],
                  ),
                ),

                Center(
                  child: Text("NFT", style: TextStyle(color: Colors.white)),
                ),
                Center(
                  child: Text("News", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),

      //bottomNavigationBar: CustomBottomNavBar(isPortrait: isPortrait)
    );
  }

  // Widget _buildTabBar() {
  //   return TabBar(
  //     controller: _tabController,
  //     labelColor: Colors.white,
  //     unselectedLabelColor: Colors.grey,
  //     indicatorColor: Colors.deepPurpleAccent,
  //     tabs: const [
  //       Tab(text: 'Coin'),
  //       Tab(text: 'NFT'),
  //       Tab(text: 'News'),
  //     ],
  //   );
  // }

  Widget _buildFilterGrid(double width, bool isPortrait) {
    final crossAxisCount = isPortrait ? 5 : 8;
    final itemWidth = width / crossAxisCount - 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: List.generate(filters.length, (index) {
          final item = filters[index];
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              width: itemWidth,
              height: 40,
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Colors.deepPurpleAccent
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (item['title'] == '') // last icon only
                      Icon(Icons.open_in_full, color: Colors.white, size: 18)
                    else
                      Text(
                        item['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        softWrap: false,
                      ),
                    if (item['change'] != null)
                      Text(
                        item['change'],
                        style: TextStyle(
                          fontSize: 11,
                          color: item['change'].toString().startsWith('+')
                              ? Colors.green
                              : Colors.red,
                        ),
                      )
                    else
                      const SizedBox(
                        height: 14,
                      ), // ✅ fills space for uniformity
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
