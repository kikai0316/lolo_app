import 'dart:ui';

import 'package:flutter/material.dart';

Widget nText(
  String text, {
  required Color color,
  required double fontSize,
  required double bold,
}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      decoration: TextDecoration.none,
      fontFamily: "Normal",
      fontVariations: [FontVariation("wght", bold)],
      color: color,
      fontSize: fontSize,
    ),
  );
}

Widget nTextWithShadow(
  String text, {
  required Color color,
  required double fontSize,
  required double bold,
}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      decoration: TextDecoration.none,
      fontFamily: "Normal",
      shadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 1.0,
        )
      ],
      fontVariations: [FontVariation("wght", bold)],
      color: color,
      fontSize: fontSize,
    ),
  );
}

const String initEventDetails = """
【イベント概要】
[イベントの説明や特徴、ジャンル、目玉となる内容など]


【チケット情報】
前売り: [前売りチケットの価格]
当日: [当日チケットの価格]
チケット購入先: [チケット購入リンクや方法]


【注意事項】
- [年齢制限、ドレスコード、持ち物などの注意事項]
- [COVID-19関連の特別な注意事項や健康安全対策]


【お問い合わせ】
[連絡先の電話番号やメールアドレス]
[イベントのウェブサイトやSNSリンク]

※イベントの詳細は変更になる場合があります。最新の情報はウェブサイトをご確認ください。""";
