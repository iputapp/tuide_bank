//packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:figma_squircle/figma_squircle.dart';

//riverpods
import '../../../view_model/charge_riverpod.dart';
import '../../../view_model/all_price.dart';
import '../../../view_model/user_log.dart';
import '../../../view_model/temporary_list.dart';

//commons
import '../../../commons/navigation_bar/navigation_bar.dart';

//freezed
import '../../../model/save.dart';

class CalculatorButton extends ConsumerWidget {
  const CalculatorButton({
    super.key,
    required this.buttonText,
    this.isEnabled = true, //　金額が0の場合ボタンを押せないようにするので、そこで使用する変数です。 デフォルトはtrue
  });

  final String buttonText;
  final bool isEnabled; // ボタンの有効/無効状態

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;
    final chageState = ref.watch(chargeRiverpodNotifierProvider); 
    final temporaryList = ref.watch(temporaryListNotifierProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
      child: Container(
        height: 65,
        width: 65, 
        child: ElevatedButton(
          onPressed: isEnabled ? () {
            final chargeNotifier = ref.read(chargeRiverpodNotifierProvider.notifier);
            if (RegExp(r'^\d$').hasMatch(buttonText)) {
              chargeNotifier.addNumber(buttonText);
            } else if (buttonText == 'del') {
              chargeNotifier.deleteNumber();
            } else if (buttonText == 'C') {
              chargeNotifier.cancelCharge(); 
            } else if (buttonText == '税') {
              chargeNotifier.tax_include(); 
            } else if (buttonText == '→' && int.parse(chageState) != 0) {
              chargeNotifier.cancelCharge(); 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommonNavigationBar(initialIndex: 0),
                ),
              );
              final allNotifier = ref.read(allPriceNotifierProvider.notifier);  // 全体の値を変更するnotifierを取得
              allNotifier.updateAllPrice(int.parse(chageState)); // 全体の値にchargeStateを追加
              final temporaryListNotifier = ref.read(temporaryListNotifierProvider.notifier);
              final userLogNotifier = ref.read(userLogNotifierProvider.notifier); //
              // Save クラスのインスタンスを作成
              final save = Save(
                name: temporaryList[0] as String, // カテゴリ名
                icon: temporaryList[1] as IconData, // カテゴリアイコン
                color: temporaryList[2] as Color, // カテゴリカラー
                price: int.parse(chageState), // 価格
                deposit: true, // 必要に応じて true または false に設定
                dataTime: DateTime.now(),
                memo: "",
                imageUrl: "",
                salePercentage: 0,
              );
              // Save インスタンスを updateState に渡す
              userLogNotifier.updateState(save);
              temporaryListNotifier.resetState();
            }
          } : null, // isEnabledがfalseの場合はボタンを無効化
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.zero, // ボタンの内側の余白をなしに設定
            backgroundColor: Color(0xff008816), // isEnabledに基づいて背景色を変更
            shape: const CircleBorder(), 
            alignment: Alignment.center, 
          ),
          child: Text(
            buttonText,
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: size.width * 0.07,
              fontWeight: FontWeight.bold, 
              color: isEnabled ? Colors.white : Colors.grey, // isEnabledに基づいてテキストの色を変更
            ),
          ),
        ),
      ),
    );
  }
}

// 00のボタンのみサイズが異なる専用のウィジェット
class BigCalculatorButton extends ConsumerWidget {
  const BigCalculatorButton({
    super.key,
    required this.buttonText,
    this.isEnabled = true, //　金額が0の場合ボタンを押せないようにするので、そこで使用する変数です。 デフォルトはtrue
  });

  final String buttonText; 
  final bool isEnabled; // ボタンの有効/無効状態

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.fromLTRB(9, 5, 9, 5),
      child: Container(
        height: 65, 
        width: 148, 
        child: ElevatedButton(
          onPressed: isEnabled ? () {
            final chargeNotifier = ref.read(chargeRiverpodNotifierProvider.notifier); 
            chargeNotifier.addNumber('$buttonText'); 
          } : null, // isEnabledがfalseの場合はボタンを無効化
          style: ElevatedButton.styleFrom(
            elevation: 0, 
            alignment: Alignment.center,
            backgroundColor:Color(0xff008816), // isEnabledに基づいて背景色を変更
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100), // 高さの半分で最大角丸
            ),
          ),
          child: Text(
            buttonText, 
            style: TextStyle(
              fontSize: size.width * 0.07, 
              fontWeight: FontWeight.bold, 
              color: isEnabled ? Colors.white : Colors.grey, // isEnabledに基づいてテキストの色を変更
            ),
          ),
        ),
      ),
    );
  }
}