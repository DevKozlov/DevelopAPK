#Если Сервер ИЛИ ТолстыйКлиентОбычноеПриложение ИЛИ ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Создает новый табличный документ с СКД из переданного отчета, с настройками по умолчанию.
// Параметры:
//   ИмяОтчета - Отчет-источник, откуда получаем макет СКД.
//   ПараметрыНастроек - Параметры для создания табличного документа.
//   Настройки - Настройки, для которых необходимо создать макет.
//   ТаблицаЗначенийРезультат - Таблица значений.
// Возвращаемое значение:
//   Табличный документ.
Функция СформироватьТабличныйДокументИзФоновогоЗадания(ПараметрыОтчета, АдресХранилища) Экспорт
	
	ИмяОтчета = ПараметрыОтчета.ИмяОтчета;
	ПараметрыНастроек = ПараметрыОтчета.ПараметрыНастроек;
	Настройки = ПараметрыОтчета.Настройки;
	ТаблицаЗначенийРезультат = ПараметрыОтчета.ТаблицаЗначенийРезультат;
	
	ДанныеОтчета = Новый Структура;
	ДанныеОтчета.Вставить("ИмяОтчета", ИмяОтчета);
	ДанныеОтчета.Вставить("ОписаниеОшибки", "");
	ДанныеОтчета.Вставить("ОжиданиеОтвета", Ложь);
	ДанныеОтчета.Вставить("ИмяТабличнойЧасти", ПараметрыОтчета.ИмяТабличнойЧасти);
	
	// Получаем СКД.
	Схема = Отчеты.НайденныеОшибки.ПолучитьМакет(ИмяОтчета);
	
	Для Каждого ЗначениеПараметра Из Схема.Параметры Цикл
		ЗначениеКУстановке = ПараметрыНастроек[ЗначениеПараметра.Имя];
		Если ЗначениеКУстановке <> Неопределено Тогда
			ЗначениеПараметра.Значение = ЗначениеКУстановке;
		КонецЕсли;
	КонецЦикла;
	
	// Получаем настройки по умолчанию.
	Если Настройки = Неопределено Тогда
		Настройки = Схема.НастройкиПоУмолчанию;
	КонецЕсли;
	
	// Создаем компоновщик.
	ДанныеРасшифровкиОтчета = Новый ДанныеРасшифровкиКомпоновкиДанных;
	Компоновщик = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = Компоновщик.Выполнить(Схема, Настройки, ДанныеРасшифровкиОтчета);
	
	// Создаем процессор компоновки.
	Процессор = Новый ПроцессорКомпоновкиДанных;
	Процессор.Инициализировать(МакетКомпоновки,, ДанныеРасшифровкиОтчета);
	
	// Формируем табличный документ.
	ТабДокумент = Новый ТабличныйДокумент;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ТабДокумент);
	СтандартнаяОбработка = Ложь;
	
	Попытка
		ПроцессорВывода.Вывести(Процессор, Истина);
	Исключение
		ДанныеОтчета.Вставить("ОписаниеОшибки", ОписаниеОшибки());
	КонецПопытки;
	
	Если ТаблицаЗначенийРезультат <> Неопределено Тогда
		
		КомпоновщикДляТаблицыЗначений = Новый КомпоновщикМакетаКомпоновкиДанных;
		МакетКомпоновкиДляТаблицыЗначений = КомпоновщикДляТаблицыЗначений.Выполнить(Схема, Настройки,,,
			Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
		
		ПроцессорДляТаблицыЗначений = Новый ПроцессорКомпоновкиДанных;
		ПроцессорДляТаблицыЗначений.Инициализировать(МакетКомпоновкиДляТаблицыЗначений,, ДанныеРасшифровкиОтчета);
		
		ПроцессорВыводаВКоллекцию = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
		ТаблицаЗначенийРезультат = Новый ТаблицаЗначений;
		ПроцессорВыводаВКоллекцию.УстановитьОбъект(ТаблицаЗначенийРезультат);
		ПроцессорВыводаВКоллекцию.Вывести(ПроцессорДляТаблицыЗначений, Истина);
		
	КонецЕсли;
	
	ДанныеОтчета.Вставить("ТабличныйДокумент", ТабДокумент);
	ДанныеОтчета.Вставить("ДанныеРасшифровкиОтчета", ДанныеРасшифровкиОтчета);
	ПоместитьВоВременноеХранилище(ЗначениеВСтрокуXML(ДанныеОтчета), АдресХранилища);
	
КонецФункции

// Возвращает значение в виде XML-строки.
// Преобразованы в XML-строку (сериализованы) могут быть только те объекты,
// для которых в описании указано, что они сериализуются.
//
// Параметры:
//   Значение - Произвольный. Значение, которое необходимо сериализовать в XML-строку.
//
// Возвращаемое значение:
//   Строка - XML-строка представления значения в сериализованном виде.
//
Функция ЗначениеВСтрокуXML(Значение)
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку();
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, Значение, НазначениеТипаXML.Явное);
	
	Возврат ЗаписьXML.Закрыть();
	
КонецФункции

#КонецОбласти

#КонецЕсли