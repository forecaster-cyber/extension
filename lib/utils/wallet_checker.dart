import 'dart:convert';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/auth/password_screen.dart';
import 'package:defi_wallet/screens/auth/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/auth/signup/signup_phrase_screen.dart';
import 'package:defi_wallet/screens/auth/welcome_screen.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/ui_kit.dart';
import 'package:defi_wallet/services/storage_service.dart';
import 'package:defi_wallet/utils/theme/theme_checker.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class WalletChecker extends StatefulWidget {
  @override
  State<WalletChecker> createState() => _WalletCheckerState();
}

class _WalletCheckerState extends State<WalletChecker> {
  SettingsHelper settingsHelper = SettingsHelper();
  LockHelper lockHelper = LockHelper();
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  @override
  Widget build(BuildContext context) {
    Future<void> checkWallets() async {
      try {
        await StorageService.updateExistUsers();
      } catch (err) {
        await Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                ThemeChecker(LockScreen()),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }

      AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
      BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
      var box = await Hive.openBox(HiveBoxes.client);
      var masterKeyPairName;
      if (SettingsHelper.settings.network! == 'testnet') {
        masterKeyPairName = HiveNames.masterKeyPairTestnetPrivate;
      } else {
        masterKeyPairName = HiveNames.masterKeyPairMainnetPrivate;
      }
      var masterKeyPair = await box.get(masterKeyPairName);
      var password = await box.get(HiveNames.password);
      bool isSavedMnemonic = await box.get(HiveNames.openedMnemonic) != null;
      String? savedMnemonic = await box.get(HiveNames.openedMnemonic);

      bool isRecoveryMnemonic =
          await box.get(HiveNames.recoveryMnemonic) != null;
      String? recoveryMnemonic = await box.get(HiveNames.recoveryMnemonic);

      bool isLedger =
          await box.get(HiveNames.ledgerWalletSetup, defaultValue: false);

      await settingsHelper.loadSettings();
      await box.close();

      if (masterKeyPair != null || isLedger) {
        if (password != null || isLedger) {
          lockHelper.provideWithLockChecker(context, () async {
            try {
              await accountCubit
                  .restoreAccountFromStorage(SettingsHelper.settings.network!);
            } catch (err) {
              print(err);
            }
            if (SettingsHelper.isBitcoin()) {
              await bitcoinCubit
                  .loadDetails(accountCubit.state.accounts![0].bitcoinAddress!);
            }
            await Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    ThemeChecker(HomeScreen(
                  isLoadTokens: true,
                )),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          });
        } else {
          try {
            await accountCubit
                .restoreAccountFromStorage(SettingsHelper.settings.network!);
          } catch (err) {
            print(err);
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => ThemeChecker(
                PasswordScreen(
                  onSubmitted: (String password) {
                    // need to recovery
                  },
                ),
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      } else {
        if (isSavedMnemonic) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  ThemeChecker(SignupPhraseScreen(mnemonic: savedMnemonic)),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          if (isRecoveryMnemonic) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    ThemeChecker(RecoveryScreen(
                  mnemonic: recoveryMnemonic,
                )),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    ThemeChecker(WelcomeScreen()),
                    // ThemeChecker(UiKit()),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        }
      }
    }

    checkWallets();

    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      child: Center(child: Loader()),
    );
  }
}
