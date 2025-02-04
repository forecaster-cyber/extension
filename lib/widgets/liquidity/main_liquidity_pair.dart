import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_remove_screen.dart';
import 'package:defi_wallet/screens/liquidity/remove_liquidity.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_select_pool.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/liquidity/liquidity_asset_pair.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MainLiquidityPair extends StatefulWidget {
  final AssetPairModel? assetPair;
  final Function(AssetPairModel)? callback;
  final int? balance;
  final bool isOpen;

  const MainLiquidityPair({
    Key? key,
    this.assetPair,
    this.callback,
    this.balance,
    this.isOpen = true,
  }) : super(key: key);

  @override
  State<MainLiquidityPair> createState() => _MainLiquidityPairState();
}

class _MainLiquidityPairState extends State<MainLiquidityPair> with ThemeMixin {
  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return GestureDetector(
      onTap: () {
        if(widget.callback != null) {
          widget.callback!(widget.assetPair!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            right: 20,
            top: 16,
            bottom: 16,
            left: 16,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDarkTheme()
                  ? DarkColors.assetItemSelectorBorderColor.withOpacity(0.16)
                  : LightColors.assetItemSelectorBorderColor.withOpacity(0.16),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              child: AssetPair(
                                pair: widget.assetPair!.symbol!,
                                // size: 25,
                              ),
                            ),
                            SizedBox(
                              width: 11,
                            ),
                            Expanded(
                              child: TickerText(
                                child: Text(
                                  TokensHelper()
                                      .getTokenFormat(widget.assetPair!.symbol),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        fontSize: 16,
                                      ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5,),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if(widget.isOpen)Expanded(child: LiquidityAssetPair(assetPair: widget.assetPair, balance: widget.balance),),
                ],
              ),
              if(widget.isOpen)SizedBox(height: 16,),
              if(widget.isOpen)Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 140,
                    child: AccentButton(
                      callback: () {
                        lockHelper.provideWithLockChecker(
                          context,
                              () =>
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation1,
                                      animation2) =>
                                      LiquidityRemoveScreen(
                                        assetPair: widget.assetPair!,
                                        balance: widget.balance!,
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              ),
                        );
                      },
                      label: 'Remove',
                    ),
                  ),
                  NewPrimaryButton(
                    width: 140,
                    callback: (){
                      lockHelper.provideWithLockChecker(
                        context,
                            () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                LiquiditySelectPool(
                                  assetPair: widget.assetPair!,
                                ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        ),
                      );
                    },
                    title: 'Add Liquidity',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
