import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/addresses_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/screens/address_book/address_book_screen.dart';
import 'package:defi_wallet/screens/send/send_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressBookAddScreen extends StatefulWidget {
  final String? name;
  final String? address;
  final int? id;
  final bool isRedirect;

  const AddressBookAddScreen({
    Key? key,
    this.name,
    this.address,
    this.id,
    this.isRedirect = false,
  }) : super(key: key);

  @override
  _AddressBookAddScreenState createState() => _AddressBookAddScreenState();
}

class _AddressBookAddScreenState extends State<AddressBookAddScreen> {
  AddressesHelper addressHelper = AddressesHelper();
  final _formKey = GlobalKey<FormState>();
  final _focusNodeName = FocusNode();
  final _focusNodeAddress = FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool isNew = true;
  bool isEnable = false;
  bool isValidAddress = false;
  int counter = 0;


  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        if (counter == 0) {
          if (widget.name != null && widget.address != null) {
            nameController.text = widget.name!;
            addressController.text = widget.address!;
            isNew = false;
            isEnable = true;
          }
          counter++;
        }
        return Scaffold(
          appBar: MainAppBar(
            title: 'Add new address',
            isShowBottom: !(txState is TransactionInitialState),
            height: !(txState is TransactionInitialState)
                ? ToolbarSizes.toolbarHeightWithBottom
                : ToolbarSizes.toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding:
                const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              'Name:',
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                          GestureDetector(
                            onDoubleTap: () {
                              _focusNodeName.requestFocus();
                              nameController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: nameController.text.length);
                            },
                            child: TextFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                hoverColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppTheme.pinkColor),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                hintStyle: TextStyle(fontSize: 14),
                              ),
                              onFieldSubmitted: (value) =>
                                  _focusNodeAddress.requestFocus(),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                              ],
                              focusNode: _focusNodeName,
                              controller: nameController,
                              onChanged: (value) => checkButtonStatus(),
                              validator: (value) {
                                if (nameController.text.length > 3) {
                                  return null;
                                } else {
                                  return 'Must be at least 3 characters';
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              'Address:',
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ),
                          GestureDetector(
                            onDoubleTap: () {
                              _focusNodeAddress.requestFocus();
                              addressController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: addressController.text.length);
                            },
                            child: TextFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                hoverColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppTheme.pinkColor),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                hintStyle: TextStyle(fontSize: 14),
                              ),
                              focusNode: _focusNodeAddress,
                              onFieldSubmitted: (value) => saveButtonValidation(),
                              controller: addressController,
                              onChanged: (value) async {
                                checkButtonStatus();
                                if (SettingsHelper.isBitcoin()) {
                                  isValidAddress = await addressHelper
                                      .validateBtcAddress(addressController.text);
                                } else {
                                  isValidAddress = await addressHelper
                                      .validateAddress(addressController.text);
                                }
                              },
                              validator: (value) {
                                if (widget.address != addressController.text) {
                                  if (isValidAddress) {
                                    return null;
                                  } else {
                                    return 'Invalid address';
                                  }
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Save',
                            isCheckLock: false,
                            callback: isEnable ? saveButtonValidation : null,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  checkButtonStatus() {
    setState(() {
      if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
        isEnable = true;
      } else {
        isEnable = false;
      }
    });
  }

  saveButtonValidation() {
    if (_formKey.currentState!.validate()) {
      if (isNew) {
        AddressBookCubit addressBookCubit =
            BlocProvider.of<AddressBookCubit>(context);
        addressBookCubit.addAddress(AddressBookModel(
          name: nameController.text,
          address: addressController.text,
        ));
      } else {
        AddressBookCubit addressBookCubit =
            BlocProvider.of<AddressBookCubit>(context);
        addressBookCubit.editAddress(
          AddressBookModel(
            name: nameController.text,
            address: addressController.text,
          ),
          widget.id!,
        );
      }
      if (!widget.isRedirect) {
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  AddressBookScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      } else {
        Navigator.pop(context);
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => SendScreen(
                selectedAddress: addressController.text,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      }
    }
  }
}
