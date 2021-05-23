# Localization Generator

Generate json localization file from excel sheet

## How to use

- create an excel sheet and rename sheet's name to **Translation**

- Create a data structure like below or you can check file **translation_example.xlsx** in this repo

| Key         | en-US       | km-KH   | es-ES          | th-TH | vi-VN  |
| ----------- | ----------- | ------- | -------------- | ----- | ------ |
| title       | Title       | ចំណងជើង | titulo         | dgh   | dfghjk |
| buy_account | Buy Account | ទិញគណនី | comprar cuenta | sfgg  | evsd   |
| cancel      | Cancel      | បោះបង់  | asdfaf         | add   | dfrw   |

## Result

- you will get json files base on many languages you had in your excel file
- a static class **LocaleKeys** to access your json key

## Usage

Using with easy_localization package: `Text(LocaleKeys.title.tr())`

## Screenshot

![alt text](screenshot.PNG "screenshot")

## Localization Generator

- Author: Chunlee Thong
- Contributor: Chunlee Thong

Copyright (c) 2021 Chunlee Thong
