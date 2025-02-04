import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/address_book/address_book_screen_new.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/settings/setting_screen.dart';
import 'package:defi_wallet/utils/theme/theme_manager.dart';
import 'package:defi_wallet/widgets/account_drawer/selected_account.dart';
import 'package:defi_wallet/widgets/buttons/account_menu_button.dart';
import 'package:defi_wallet/widgets/dialogs/create_edit_account_dialog.dart';
import 'package:defi_wallet/widgets/defi_switch.dart';
import 'package:defi_wallet/widgets/dialogs/wallet_lock_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/utils/theme/theme.dart';

class AccountDrawer extends StatefulWidget {
  final double? width;

  const AccountDrawer({
    Key? key,
    this.width = 280,
  }) : super(key: key);

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> with ThemeMixin {
  LockHelper lockHelper = LockHelper();
  late double accountsSelectorHeight;

  void lockWallet() async {
    await lockHelper.lockWallet();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => LockScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (BuildContext context, state) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        var accounts = state.accounts;
        if (accounts!.length == 1) {
          accountsSelectorHeight = 195;
        }
        else if (accounts.length == 2) {
          accountsSelectorHeight = 237;
        } else {
          accountsSelectorHeight = 260;
        }
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
          child: Drawer(
            width: widget.width!,
            backgroundColor: Colors.transparent,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkTheme()
                      ? DarkColors.drawerBgColor
                      : LightColors.drawerBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 1,
                    color: isDarkTheme()
                        ? DarkColors.drawerBorderColor
                        : LightColors.drawerBorderColor,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: accountsSelectorHeight,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .selectedRowColor
                                  .withOpacity(0.07),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 11,
                                    top: 11,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        child: IconButton(
                                          splashRadius: 12,
                                          padding: const EdgeInsets.all(0),
                                          onPressed: () => Scaffold.of(context)
                                              .closeEndDrawer(),
                                          icon: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SelectedAccount(
                                        accountName: state.activeAccount!.name!,
                                        onEdit: () {
                                          showDialog(
                                            barrierColor: AppColors.tolopea.withOpacity(0.06),
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return CreateEditAccountDialog(
                                                callback: (s) {
                                                  setState(() {
                                                    accountCubit.editAccount(s,
                                                        index: state
                                                            .activeAccount!
                                                            .index);
                                                  });
                                                },
                                                index:
                                                    state.activeAccount!.index,
                                                name: state.activeAccount!.name,
                                                isEdit: true,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      Expanded(
                                        child: ScrollConfiguration(
                                          behavior:
                                              ScrollConfiguration.of(context)
                                                  .copyWith(scrollbars: false),
                                          child: ListView.builder(
                                            itemCount: accounts.length,
                                            itemBuilder: (context, index) {
                                                return Column(
                                                  children: [
                                                    Divider(
                                                      height: 1,
                                                      endIndent: 12,
                                                      indent: 12,
                                                      color: Theme.of(context)
                                                          .dividerColor
                                                          .withOpacity(0.05),
                                                      thickness: 1,
                                                    ),
                                                    AccountMenuButton(
                                                      accountSelectMode: true,
                                                      account: accounts[index],
                                                      callback: accounts[index]
                                                                  .index ==
                                                              state
                                                                  .activeAccount!
                                                                  .index
                                                          ? null
                                                          : (accountIndex) async {
                                                              accountCubit
                                                                  .updateActiveAccount(
                                                                      accounts[
                                                                              index]
                                                                          .index!);
                                                              Scaffold.of(
                                                                      context)
                                                                  .closeEndDrawer();
                                                            },
                                                      isHoverBackgroundEffect:
                                                          false,
                                                      iconPath:
                                                          'assets/icons/add.svg',
                                                      title:
                                                          accounts[index].name!,
                                                    ),
                                                  ],
                                                );
                                            },
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Divider(
                                            height: 1,
                                            endIndent: 12,
                                            indent: 12,
                                            color: Theme.of(context)
                                                .dividerColor
                                                .withOpacity(0.05),
                                            thickness: 1,
                                          ),
                                          AccountMenuButton(
                                            callback: (index) {
                                              showDialog(
                                                barrierColor:
                                                AppColors.tolopea.withOpacity(0.06),
                                                barrierDismissible:
                                                false,
                                                context: context,
                                                builder: (BuildContext
                                                context) {
                                                  return CreateEditAccountDialog(
                                                    callback:
                                                        (s) async {
                                                      await accountCubit
                                                          .addAccount();
                                                      accountCubit.editAccount(
                                                          s,
                                                          index: accounts
                                                              .length -
                                                              1);
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            isHoverBackgroundEffect:
                                            false,
                                            iconPath:
                                            'assets/icons/add.svg',
                                            title:
                                            'Create new account',
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          AccountMenuButton(
                            callback: (index) {
                              Scaffold.of(context).closeEndDrawer();
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          AddressBookScreenNew(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            iconPath: 'assets/icons/address_book.svg',
                            title: 'Address Book',
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AccountMenuButton(
                            callback: (index) {
                              Scaffold.of(context).closeEndDrawer();
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          SettingScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                            iconPath: 'assets/icons/setting.svg',
                            title: 'Settings',
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AccountMenuButton(
                            callback: (index) {},
                            iconPath: 'assets/icons/ledger.svg',
                            title: 'Ledger',
                            isFuture: true,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AccountMenuButton(
                            isTheme: true,
                            callback: (index) {
                              ThemeManager.changeTheme(context);
                            },
                            iconPath: isDarkTheme()
                                ? 'assets/icons/light_mode.svg'
                                : 'assets/icons/night_mode.svg',
                            hoverBgColor: isDarkTheme()
                                ? AppColors.white
                                : AppColors.blackRock,
                            hoverTextColor: isDarkTheme()
                                ? AppColors.blackRock
                                : AppColors.white,
                            title: 'Night Mode',
                            afterTitleWidget: DefiSwitch(
                              isEnable: isDarkTheme(),
                              onToggle: (bool value) {
                                ThemeManager.changeTheme(context);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AccountMenuButton(
                            isStaticBg: true,
                            callback: (index) {},
                            iconPath: 'assets/icons/jelly_theme_explore.svg',
                            title: 'Explore Jelly themes',
                            isFuture: true,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Divider(
                            height: 8,
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.05),
                            thickness: 1,
                          ),
                          AccountMenuButton(
                            isLockType: true,
                            callback: (index) {
                              lockWallet();
                            },
                            iconPath: 'assets/icons/lock.svg',
                            title: 'Lock Wallet',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
