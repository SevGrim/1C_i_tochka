## Как пользоваться обработкой

#### Вкладка "Данные"
Для заполнения списка таблиц необходимо воспользоваться кнопкой "Заполнить". После чего в списке слева можно выбирать таблицу, а справа будут отображаться ее поля и индексы.

#### Вкладка "Преобразования"
Для перевода имен таблиц/полей/индексов СУБД в терминологию 1С необходимо поместить исходный текст/запрос в поле ввода слева, нажать на кнопку "Преобразовать" и результат расшифровка разместится в поле ввода справа. 

```
// Программный интерфейс данной функциональности.

// Функция - Преобразовать строку из sql в 1С.
//
// Параметры:
//  ВходнаяСтрока	 - Строка - Строка для преобразования.
// 
// Возвращаемое значение:
//  Строка - Расшированная строка.
//
&НаСервереБезКонтекста
Функция ПреобразоватьСтрокуИзSqlВ1С(ВходнаяСтрока)
	
	ВыходнаяСтрока = "";
	Если НЕ ЗначениеЗаполнено(ВходнаяСтрока) Тогда
		Возврат ВыходнаяСтрока;
	КонецЕсли;
	
	ТаблицаПереводов = ТаблицаРасшифровкиСтруктурыХранения();
	
	ТаблицаПереводов.Сортировать("ДлинаИмяSQL УБЫВ, ДлинаИмя1С УБЫВ");
	
	ВыходнаяСтрока = ВходнаяСтрока;
	Для Каждого ТекСтрока Из ТаблицаПереводов Цикл
		ВыходнаяСтрока = СтрЗаменить(ВыходнаяСтрока, ТекСтрока.ИмяSQL, ТекСтрока.Имя1С);
	КонецЦикла;
	
	Возврат ВыходнаяСтрока;
	
КонецФункции

// Функция - Получить таблицу соответствия переводов SQL - 1C.
//
// Параметры:
//  УбиратьСпецСимволы	 - Булево - Имена полей могут содержать "_", но при выборке они его не указывают.
//									Стоит убирать для более понятного перевода.
// 
// Возвращаемое значение:
//  ТаблицаЗначений - Таблица переводов.
//
&НаСервереБезКонтекста
Функция ТаблицаРасшифровкиСтруктурыХранения(УбиратьСпецСимволы = Истина)
	
	ТаблицаСтруктурыХранения = ПолучитьСтруктуруХраненияБазыДанных(,Истина);
	
	ТаблицаРасшифровки = Новый ТаблицаЗначений;
	ТаблицаРасшифровки.Колонки.Добавить("ИмяSQL", Новый ОписаниеТипов("Строка"));
	ТаблицаРасшифровки.Колонки.Добавить("Имя1С", Новый ОписаниеТипов("Строка"));
	
	Для Каждого ТекСтрока Из ТаблицаСтруктурыХранения Цикл
		НоваяСтрока = ТаблицаРасшифровки.Добавить();
		НоваяСтрока.ИмяSQL = ТекСтрока.ИмяТаблицыХранения;
		НоваяСтрока.Имя1С = ТекСтрока.ИмяТаблицы;
		
		// У служебных таблиц реквизит Имя1С может быть пустое. Потому дозаполним его.
		Если НЕ ЗначениеЗаполнено(НоваяСтрока.Имя1С) Тогда
			Если ЗначениеЗаполнено(ТекСтрока.Метаданные) Тогда
				НоваяСтрока.Имя1С = СтрШаблон("%1.%2", ТекСтрока.Метаданные, ТекСтрока.Назначение);
			Иначе
				НоваяСтрока.Имя1С = ТекСтрока.Назначение;
			КонецЕсли;
		КонецЕсли;
		
		Для Каждого ТекСтрокаПоля Из ТекСтрока.Поля Цикл
			НоваяСтрока = ТаблицаРасшифровки.Добавить();
			НоваяСтрока.ИмяSQL = ТекСтрокаПоля.ИмяПоляХранения;
			НоваяСтрока.Имя1С = ТекСтрокаПоля.ИмяПоля;
		КонецЦикла;
		
		Для Каждого ТекСтрокаИндекса Из ТекСтрока.Индексы Цикл
			Для Каждого ТекСтрокаПоля Из ТекСтрокаИндекса.Поля Цикл
				НоваяСтрока = ТаблицаРасшифровки.Добавить();
				НоваяСтрока.ИмяSQL = ТекСтрокаПоля.ИмяПоляХранения;
				НоваяСтрока.Имя1С = ТекСтрокаПоля.ИмяПоля;
				Если ЗначениеЗаполнено(НоваяСтрока.Имя1С) Тогда
					Продолжить;
				КонецЕсли;
				ИмяМетаданных = СтрРазделить(ТекСтрокаПоля.Метаданные, ".", Ложь);
				Если НЕ ЗначениеЗаполнено(ИмяМетаданных) Тогда
					Продолжить;
				КонецЕсли;
				НоваяСтрока.Имя1С = ИмяМетаданных[ИмяМетаданных.ВГраница()];
			КонецЦикла;
		КонецЦикла;
		
	КонецЦикла;
	
	// Ряд реквизитов может дублироваться. Например, разделитель данных.
	ТаблицаРасшифровки.Свернуть("ИмяSQL, Имя1С");
	
	ТаблицаРасшифровки.Колонки.Добавить("ДлинаИмяSQL", Новый ОписаниеТипов("Число"));
	ТаблицаРасшифровки.Колонки.Добавить("ДлинаИмя1С", Новый ОписаниеТипов("Число"));
	
	АвтоматическиеИмена1С = Новый Соответствие;
	Для Каждого ТекСтрока Из ТаблицаРасшифровки Цикл
		
		Если НЕ ЗначениеЗаполнено(ТекСтрока.Имя1С) Тогда
			Продолжить;
		КонецЕсли;
		
		АвтоматическиеИмена1С[ТекСтрока.ИмяSQL] = ТекСтрока.Имя1С;
		
	КонецЦикла;
	
	Для Каждого ТекСтрока Из ТаблицаРасшифровки Цикл
		
		Если НЕ ЗначениеЗаполнено(ТекСтрока.Имя1С) Тогда
			НайденноеИмя1С = АвтоматическиеИмена1С[ТекСтрока.ИмяSQL];
			Если НайденноеИмя1С = Неопределено Тогда
				НайденноеИмя1С = ТекСтрока.ИмяSQL;
			КонецЕсли;
			ТекСтрока.Имя1С = НайденноеИмя1С;
		КонецЕсли;
		
		Если УбиратьСпецСимволы 
			И СтрНачинаетсяС(ТекСтрока.ИмяSQL,"_") Тогда
			ТекСтрока.ИмяSQL = Сред(ТекСтрока.ИмяSQL, 2);
		КонецЕсли;
		
		Если УбиратьСпецСимволы 
			И СтрНачинаетсяС(ТекСтрока.Имя1С,"_") Тогда
			ТекСтрока.Имя1С = Сред(ТекСтрока.Имя1С, 2);
		КонецЕсли;
		
		Если НЕ ТекСтрока.Имя1С = ТекСтрока.ИмяSQL 
			И СтрНайти(ТекСтрока.ИмяSQL, "TRef") > 0 Тогда
			ТекСтрока.Имя1С = СтрШаблон(НСтр("ru='Тип%1'"), ТекСтрока.Имя1С);
		КонецЕсли;
		
		ТекСтрока.ДлинаИмяSQL = СтрДлина(ТекСтрока.ИмяSQL);
		ТекСтрока.ДлинаИмя1С = СтрДлина(ТекСтрока.Имя1С);
		
	КонецЦикла;

	Возврат ТаблицаРасшифровки;
КонецФункции
```