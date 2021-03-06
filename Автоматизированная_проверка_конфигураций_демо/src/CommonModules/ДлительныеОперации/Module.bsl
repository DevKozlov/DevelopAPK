#Область ПрограммныйИнтерфейс

// Запустить выполнение процедуры в фоновом задании, если это возможно.
// При выполнении любого из следующих условий запуск выполняется не в фоне, а сразу в основном потоке:
//  * если приложение запущено в режиме отладки (параметр /C РежимОтладки) - для упрощения отладки конфигурации;
//  * если в файловой ИБ имеются активные фоновые задания - для снижения времени ожидания пользователя.
//
// Не следует использовать эту функцию, если необходимо безусловно запускать фоновое задание.
//
// Параметры:
//  ИмяПроцедуры           - Строка    - имя экспортной процедуры, которую необходимо выполнить в фоне.
//                                       У процедуры может быть два или три формальных параметра:
//                                        * Параметры       - Структура - произвольные параметры
//                                          ПараметрыПроцедуры.Обязательно;
//                                        * АдресРезультата - Строка    - адрес временного хранилища, в которое нужно
//                                          поместить результат работы процедуры. Обязательно;
//                                        * АдресДополнительногоРезультата - Строка - если в ПараметрыВыполнения
//                                          установлен параметр ДополнительныйРезультат, то содержит адрес
//                                          дополнительного временного хранилища,в которое нужно поместить результат
//                                          работы процедуры. Опционально.
//  ПараметрыПроцедуры     - Структура - произвольные параметры вызова процедуры ИмяПроцедуры.
//  ПараметрыВыполнения    - Структура - см. функцию ПараметрыВыполненияВФоне.
//
// Возвращаемое значение:
//  Структура              - параметры выполнения задания:
//   * Статус               - Строка - "Выполняется", если задание еще не завершилось;
//                                     "Выполнено", если задание было успешно выполнено;
//                                     "Ошибка", если задание завершено с ошибкой;
//                                     "Отменено", если задание отменено пользователем или администратором.
//   * ИдентификаторЗадания - УникальныйИдентификатор - если Статус = "Выполняется", то содержит
//                                     идентификатор запущенного фонового задания.
//   * АдресРезультата       - Строка - адрес временного хранилища, в которое будет
//                                     помещен (или уже помещен) результат работы процедуры.
//   * АдресДополнительногоРезультата - Строка - если установлен параметр ДополнительныйРезультат,
//                                     содержит адрес дополнительного временного хранилища,
//                                     в которое будет помещен (или уже помещен) результат работы процедуры.
//   * КраткоеПредставлениеОшибки   - Строка - краткая информация об исключении, если Статус = "Ошибка".
//   * ПодробноеПредставлениеОшибки - Строка - подробная информация об исключении, если Статус = "Ошибка".
//
Функция ВыполнитьВФоне(Знач ИмяПроцедуры, Знач ПараметрыПроцедуры, Знач ПараметрыВыполнения) Экспорт
	
	АдресРезультата = ?(ПараметрыВыполнения.АдресРезультата <> Неопределено,
		ПараметрыВыполнения.АдресРезультата,
		ПоместитьВоВременноеХранилище(Неопределено, ПараметрыВыполнения.ИдентификаторФормы));
	
	Результат = Новый Структура;
	Результат.Вставить("Статус", "Выполняется");
	Результат.Вставить("ИдентификаторЗадания", Неопределено);
	Результат.Вставить("АдресРезультата", АдресРезультата);
	Результат.Вставить("АдресДополнительногоРезультата", "");
	Результат.Вставить("КраткоеПредставлениеОшибки", "");
	Результат.Вставить("ПодробноеПредставлениеОшибки", "");
	
	Если ПараметрыВыполнения.ЗапуститьНеВФоне И ПараметрыВыполнения.ЗапуститьВФоне Тогда
		Результат.Статус = "Ошибка";
		ТекстИсключения = НСтр("ru='Параметры длительной операции ""ВсегдаНеВФоне"" и ""ВсегдаВФоне""
			|не могут одновременно принимать значение Истина.'");
		Результат.КраткоеПредставлениеОшибки = ТекстИсключения;
		Результат.ПодробноеПредставлениеОшибки = ТекстИсключения;
		Возврат Результат;
	КонецЕсли;
	
	ПараметрыЭкспортнойПроцедуры = Новый Массив;
	ПараметрыЭкспортнойПроцедуры.Добавить(ПараметрыПроцедуры);
	ПараметрыЭкспортнойПроцедуры.Добавить(АдресРезультата);
	
	Если ПараметрыВыполнения.ДополнительныйРезультат Тогда
		Результат.АдресДополнительногоРезультата = ПоместитьВоВременноеХранилище(Неопределено,
			ПараметрыВыполнения.ИдентификаторФормы);
		ПараметрыЭкспортнойПроцедуры.Добавить(Результат.АдресДополнительногоРезультата);
	КонецЕсли;
	
	ЗапущеноЗаданийВФайловойИБ = 0;
	Если ИнформационнаяБазаФайловая() Тогда
		Отбор = Новый Структура;
		Отбор.Вставить("Состояние", СостояниеФоновогоЗадания.Активно);
		ЗапущеноЗаданийВФайловойИБ = ФоновыеЗадания.ПолучитьФоновыеЗадания(Отбор).Количество();
	КонецЕсли;
	
	// Выполнить в основном потоке.
	Если ПараметрыВыполнения.ЗапуститьНеВФоне
		Или (ЗапущеноЗаданийВФайловойИБ > 0 И Не ПараметрыВыполнения.ЗапуститьВФоне) Тогда
		Попытка
			РаботаВБезопасномРежиме.ВыполнитьМетодКонфигурации(ИмяПроцедуры, ПараметрыЭкспортнойПроцедуры);
			Результат.Статус = "Выполнено";
		Исключение
			Результат.Статус = "Ошибка";
			Результат.КраткоеПредставлениеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;
		Возврат Результат;
	КонецЕсли;
	
	// Выполнить в фоне.
	Попытка
		Задание = ЗапуститьФоновоеЗаданиеСКонтекстомКлиента(ИмяПроцедуры, ПараметрыЭкспортнойПроцедуры,
			ПараметрыВыполнения.КлючФоновогоЗадания, ПараметрыВыполнения.НаименованиеФоновогоЗадания);
	Исключение
		
		Результат.Статус = "Ошибка";
		Если Задание <> Неопределено И Задание.ИнформацияОбОшибке <> Неопределено Тогда
			Результат.КраткоеПредставлениеОшибки = КраткоеПредставлениеОшибки(Задание.ИнформацияОбОшибке);
			Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(Задание.ИнформацияОбОшибке);
		Иначе
			Результат.КраткоеПредставлениеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецЕсли;
		
		Возврат Результат;
		
	КонецПопытки;
	
	Результат.ИдентификаторЗадания = Задание.УникальныйИдентификатор;
	
	ЗаполнитьЗначенияСвойств(Результат, ОперацияВыполнена(Задание.УникальныйИдентификатор));
	
	Возврат Результат;
	
КонецФункции

// Возвращает новую структуру для параметра ПараметрыВыполнения функции ВыполнитьВФоне.
//
// Параметры:
//   ИдентификаторФормы - УникальныйИдентификатор - уникальный идентификатор формы,
//       во временное хранилище которой надо поместить результат выполнения процедуры.
//
// Возвращаемое значение:
//   Структура - со свойствами:
//     * ИдентификаторФормы      - УникальныйИдентификатор - уникальный идентификатор формы,
//                                 во временное хранилище которой надо поместить результат выполнения процедуры.
//     * ДополнительныйРезультат - Булево     - признак использования дополнительного временного хранилища для передачи
//                                 результата из фонового задания в родительский сеанс. По умолчанию - Ложь.
//     * ОжидатьЗавершение       - Число, Неопределено - таймаут в секундах ожидания завершения фонового задания.
//         Если задано Неопределено, то ждать до момента завершения задания.
//         Если задано 0, то ждать завершения задания не требуется.
//         По умолчанию - 2 секунды; а для низкой скорости соединения - 4.
//     * НаименованиеФоновогоЗадания - Строка - описание фонового задания. По умолчанию - имя процедуры.
//     * КлючФоновогоЗадания      - Строка    - уникальный ключ для активных фоновых заданий, имеющих такое же имя
//                                              процедуры. По умолчанию, не задан.
//     * АдресРезультата          - Строка - адрес временного хранилища, в которое должен быть помещен результат
//                                           работы процедуры. Если не задан, адрес формируется автоматически.
//     * ЗапуститьВФоне           - Булево - если Истина, то задание будет всегда выполняться в фоне,
//                                           за исключением режима отладки.
//     * ЗапуститьНеВФоне         - Булево - если Истина, задание всегда будет запускаться непосредственно,
//                                           без использования фонового задания.
//
Функция ПараметрыВыполненияВФоне(Знач ИдентификаторФормы) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("ИдентификаторФормы", ИдентификаторФормы);
	Результат.Вставить("ДополнительныйРезультат", Ложь);
	Результат.Вставить("ОжидатьЗавершение",
		?(ПолучитьСкоростьКлиентскогоСоединения() = СкоростьКлиентскогоСоединения.Низкая, 4, 2));
	Результат.Вставить("НаименованиеФоновогоЗадания", "");
	Результат.Вставить("КлючФоновогоЗадания", "");
	Результат.Вставить("АдресРезультата", Неопределено);
	Результат.Вставить("ЗапуститьНеВФоне", Ложь);
	Результат.Вставить("ЗапуститьВФоне", Ложь);
	
	Возврат Результат;
	
КонецФункции

// Отменяет выполнение фонового задания по переданному идентификатору.
//
// Параметры:
//  ИдентификаторЗадания - УникальныйИдентификатор - идентификатор фонового задания.
//
Процедура ОтменитьВыполнениеЗадания(Знач ИдентификаторЗадания) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ИдентификаторЗадания) Тогда
		Возврат;
	КонецЕсли;
	
	Задание = НайтиЗаданиеПоИдентификатору(ИдентификаторЗадания);
	Если Задание = Неопределено
		ИЛИ Задание.Состояние <> СостояниеФоновогоЗадания.Активно Тогда
		
		Возврат;
	КонецЕсли;
	
	Попытка
		Задание.Отменить();
	Исключение
		Комментарий = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		// Возможно, задание как раз в этот момент закончилось, и ошибки нет.
		ЗаписьЖурналаРегистрации(
			НСтр("ru='Длительные операции.Отмена выполнения фонового задания'", Метаданные.ОсновнойЯзык.КодЯзыка),
			УровеньЖурналаРегистрации.Предупреждение,,,
			Комментарий);
	КонецПопытки;
	
КонецПроцедуры

// Проверяет состояние фонового задания по переданному идентификатору.
// При аварийном завершении задания вызывает исключение.
//
// Параметры:
//  ИдентификаторЗадания - УникальныйИдентификатор - идентификатор фонового задания.
//
// Возвращаемое значение:
//  Булево - состояние выполнения задания.
//
Функция ЗаданиеВыполнено(Знач ИдентификаторЗадания) Экспорт
	
	Задание = НайтиЗаданиеПоИдентификатору(ИдентификаторЗадания);
	
	Если Задание <> Неопределено
		И Задание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
		Возврат Ложь;
	КонецЕсли;
	
	ОперацияНеВыполнена = Истина;
	ПоказатьПолныйТекстОшибки = Ложь;
	Если Задание = Неопределено Тогда
		ЗаписьЖурналаРегистрации(
			НСтр("ru='Длительные операции.Фоновое задание не найдено'", Метаданные.ОсновнойЯзык.КодЯзыка),
			УровеньЖурналаРегистрации.Ошибка,,,
			Строка(ИдентификаторЗадания));
	Иначе
		Если Задание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно Тогда
			ОшибкаЗадания = Задание.ИнформацияОбОшибке;
			Если ОшибкаЗадания <> Неопределено Тогда
				ПоказатьПолныйТекстОшибки = Истина;
			КонецЕсли;
		ИначеЕсли Задание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
			ЗаписьЖурналаРегистрации(
				НСтр("ru='Длительные операции.Фоновое задание отменено администратором'", Метаданные.ОсновнойЯзык.КодЯзыка),
				УровеньЖурналаРегистрации.Ошибка,,,
				НСтр("ru='Задание завершилось с неизвестной ошибкой.'"));
		Иначе
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	
	Если ПоказатьПолныйТекстОшибки Тогда
		ТекстОшибки = КраткоеПредставлениеОшибки(ПричинаОшибки(Задание.ИнформацияОбОшибке));
		ВызватьИсключение(ТекстОшибки);
	ИначеЕсли ОперацияНеВыполнена Тогда
		ВызватьИсключение(НСтр("ru='Не удалось выполнить данную операцию.
			|Подробности см. в Журнале регистрации.'"));
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Запуск фонового задания с контекстом клиента. Например, передаются ПараметрыКлиентаНаСервере.
// Запуск выполняется с помощью процедуры ВыполнитьМетодКонфигурации общего модуля РаботаВБезопасномРежиме.
//
// Параметры:
//  ИмяМетода    - Строка - как в функции Выполнить менеджера фоновых заданий.
//  Параметры    - Массив - как в функции Выполнить менеджера фоновых заданий.
//  Ключ         - Строка - как в функции Выполнить менеджера фоновых заданий.
//  Наименование - Строка - как в функции Выполнить менеджера фоновых заданий.
//
// Возвращаемое значение:
//  ФоновоеЗадание.
//
Функция ЗапуститьФоновоеЗаданиеСКонтекстомКлиента(ИмяПроцедуры, ПараметрыПроцедуры = Неопределено,
	КлючФоновогоЗадания = "", НаименованиеФоновогоЗадания = "")
	
	Если ТекущийРежимЗапуска() = Неопределено Тогда
		
		Возврат ФоновыеЗадания.Выполнить(ИмяПроцедуры, ПараметрыПроцедуры, КлючФоновогоЗадания,
			?(ПустаяСтрока(НаименованиеФоновогоЗадания), ИмяПроцедуры, НаименованиеФоновогоЗадания));
		
	КонецЕсли;
	
	ВсеПараметры = Новый Структура;
	ВсеПараметры.Вставить("ИмяПроцедуры",       ИмяПроцедуры);
	ВсеПараметры.Вставить("ПараметрыПроцедуры", ПараметрыПроцедуры);
	
	ПараметрыПроцедурыФоновогоЗадания = Новый Массив;
	ПараметрыПроцедурыФоновогоЗадания.Добавить(ВсеПараметры);
	
	Возврат ФоновыеЗадания.Выполнить("ДлительныеОперации.ВыполнитьСКонтекстомКлиента",
		ПараметрыПроцедурыФоновогоЗадания, КлючФоновогоЗадания,
		?(ПустаяСтрока(НаименованиеФоновогоЗадания), ИмяПроцедуры, НаименованиеФоновогоЗадания));
	
КонецФункции

// Продолжение процедуры ЗапуститьФоновоеЗаданиеСКонтекстомКлиента.
Процедура ВыполнитьСКонтекстомКлиента(ВсеПараметры) Экспорт
	
	РаботаВБезопасномРежиме.ВыполнитьМетодКонфигурации(ВсеПараметры.ИмяПроцедуры, ВсеПараметры.ПараметрыПроцедуры);
	
КонецПроцедуры

Функция НайтиЗаданиеПоИдентификатору(Знач ИдентификаторЗадания)
	
	Если ТипЗнч(ИдентификаторЗадания) = Тип("Строка") Тогда
		ИдентификаторЗадания = Новый УникальныйИдентификатор(ИдентификаторЗадания);
	КонецЕсли;
	
	Задание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
	Возврат Задание;
	
КонецФункции

Функция ПричинаОшибки(ИнформацияОбОшибке)
	
	Результат = ИнформацияОбОшибке;
	Если ИнформацияОбОшибке <> Неопределено Тогда
		Если ИнформацияОбОшибке.Причина <> Неопределено Тогда
			Результат = ПричинаОшибки(ИнформацияОбОшибке.Причина);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Считывает информацию о ходе выполнения фонового задания и сообщения, которые в нем были сформированы.
//
// Параметры:
//   ИдентификаторЗадания - УникальныйИдентификатор - идентификатор фонового задания.
//   Режим                - Строка - "ПрогрессИСообщения", "Прогресс" или "Сообщения".
//
// Возвращаемое значение:
//   Структура - со свойствами:
//    * Прогресс  - Неопределено, Структура - Информация о ходе выполнения фонового задания, записанная процедурой
//       СообщитьПрогресс:
//     ** Процент                 - Число  - Необязательный. Процент выполнения.
//     ** Текст                   - Строка - Необязательный. Информация о текущей операции.
//     ** ДополнительныеПараметры - Произвольный - Необязательный. Любая дополнительная информация.
//    * Сообщения - ФиксированныйМассив - Массив объектов СообщениеПользователю, которые были сформированы в фоновом
//        задании.
//
Функция ПрочитатьПрогрессИСообщения(Знач ИдентификаторЗадания, Знач Режим = "ПрогрессИСообщения")
	
	Результат = Новый Структура("Сообщения, Прогресс", Новый Массив, Неопределено);
	
	Задание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(ИдентификаторЗадания);
	Если Задание = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	МассивСообщений = Задание.ПолучитьСообщенияПользователю(Истина);
	Если МассивСообщений = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	Количество = МассивСообщений.Количество();
	Сообщения = Новый Массив;
	ЧитатьСообщения = (Режим = "ПрогрессИСообщения" Или Режим = "Сообщения");
	ЧитатьПрогресс  = (Режим = "ПрогрессИСообщения" Или Режим = "Прогресс");
	
	Если ЧитатьСообщения И Не ЧитатьПрогресс Тогда
		Результат.Сообщения = Новый ФиксированныйМассив(МассивСообщений);
		Возврат Результат;
	КонецЕсли;
	
	Для Номер = 0 По Количество - 1 Цикл
		Сообщение = МассивСообщений[Номер];
		
		Если ЧитатьПрогресс И СтрНачинаетсяС(Сообщение.Текст, "{") Тогда
			Позиция = СтрНайти(Сообщение.Текст, "}");
			Если Позиция > 2 Тогда
				ИдентификаторМеханизма = Сред(Сообщение.Текст, 2, Позиция - 2);
				Если ИдентификаторМеханизма = СообщениеПрогресса() Тогда
					ПолученныйТекст = Сред(Сообщение.Текст, Позиция + 1);
					Результат.Прогресс = ЗначениеИзСтрокиXML(ПолученныйТекст);
					Продолжить;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Если ЧитатьСообщения Тогда
			Сообщения.Добавить(Сообщение);
		КонецЕсли;
	КонецЦикла;
	
	Результат.Сообщения = Новый ФиксированныйМассив(Сообщения);
	Возврат Результат;
	
КонецФункции

// Возвращает значение, полученное из XML-строки.
// Получены из XML-строки могут быть только те объекты, для которых в описании указано, что они сериализуются.
//
// Параметры:
//   СтрокаXML - строка представления значения в сериализованном виде.
//
// Возвращаемое значение:
//   Значение, полученное из переданной XML-строки.
//
Функция ЗначениеИзСтрокиXML(СтрокаXML)
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(СтрокаXML);
	
	Возврат СериализаторXDTO.ПрочитатьXML(ЧтениеXML);
	
КонецФункции

Функция СообщениеПрогресса()
	Возврат "СтандартныеПодсистемы.ДлительныеОперации";
КонецФункции

// Определяет режим эксплуатации информационной базы файловый (Истина) или серверный (Ложь).
// При проверке используется СтрокаСоединенияИнформационнойБазы, которую можно указать явно.
//
// Параметры:
//  СтрокаСоединенияИнформационнойБазы - Строка - параметр используется, если
//                 нужно проверить строку соединения не текущей информационной базы.
//
// Возвращаемое значение:
//  Булево.
//
Функция ИнформационнаяБазаФайловая(Знач СтрокаСоединенияИнформационнойБазы = "")
	
	Если ПустаяСтрока(СтрокаСоединенияИнформационнойБазы) Тогда
		СтрокаСоединенияИнформационнойБазы =  СтрокаСоединенияИнформационнойБазы();
	КонецЕсли;
	
	Возврат СтрНайти(ВРег(СтрокаСоединенияИнформационнойБазы), "FILE=") = 1;
	
КонецФункции

Функция ОперацияВыполнена(Знач ИдентификаторЗадания, Знач ИсключениеПриОшибке = Ложь,
	Знач ВыводитьПрогрессВыполнения = Ложь, Знач ВыводитьСообщения = Ложь)
	
	Результат = Новый Структура;
	Результат.Вставить("Статус", "Выполняется");
	Результат.Вставить("КраткоеПредставлениеОшибки", Неопределено);
	Результат.Вставить("ПодробноеПредставлениеОшибки", Неопределено);
	Результат.Вставить("Прогресс", Неопределено);
	Результат.Вставить("Сообщения", Неопределено);
	
	Задание = НайтиЗаданиеПоИдентификатору(ИдентификаторЗадания);
	Если Задание = Неопределено Тогда
		ЗаписьЖурналаРегистрации(
			НСтр("ru='Длительные операции'", Метаданные.ОсновнойЯзык.КодЯзыка),
			УровеньЖурналаРегистрации.Ошибка,,,
			СтрШаблон(НСтр("ru='Фоновое задание не найдено: %1'"), ИдентификаторЗадания));
		Если ИсключениеПриОшибке Тогда
			ВызватьИсключение(НСтр("ru='Не удалось выполнить данную операцию.'"));
		КонецЕсли;
		
		Результат.Статус = "Ошибка";
		
		Возврат Результат;
	КонецЕсли;
	
	Если ВыводитьПрогрессВыполнения Тогда
		ПрогрессИСообщения = ПрочитатьПрогрессИСообщения(ИдентификаторЗадания,
			?(ВыводитьСообщения, "ПрогрессИСообщения", "Прогресс"));
		Результат.Прогресс = ПрогрессИСообщения.Прогресс;
		Если ВыводитьСообщения Тогда
			Результат.Сообщения = ПрогрессИСообщения.Сообщения;
		КонецЕсли;
	ИначеЕсли ВыводитьСообщения Тогда
		Результат.Сообщения = Задание.ПолучитьСообщенияПользователю(Истина);
	КонецЕсли;
	
	Если Задание.Состояние = СостояниеФоновогоЗадания.Активно Тогда
		Возврат Результат;
	КонецЕсли;
	
	Если Задание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
		Результат.Статус = "Отменено";
		Возврат Результат;
	КонецЕсли;
	
	Если Задание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно
	 ИЛИ Задание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда
		
		Результат.Статус = "Ошибка";
		Если Задание.ИнформацияОбОшибке <> Неопределено Тогда
			Результат.КраткоеПредставлениеОшибки   = КраткоеПредставлениеОшибки(Задание.ИнформацияОбОшибке);
			Результат.ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки(Задание.ИнформацияОбОшибке);
		КонецЕсли;
		Если ИсключениеПриОшибке Тогда
			Если Не ПустаяСтрока(Результат.КраткоеПредставлениеОшибки) Тогда
				ТекстСообщения = Результат.КраткоеПредставлениеОшибки;
			Иначе
				ТекстСообщения = НСтр("ru='Не удалось выполнить данную операцию.'");
			КонецЕсли;
			ВызватьИсключение ТекстСообщения;
		КонецЕсли;
		Возврат Результат;
	КонецЕсли;
	
	Результат.Статус = "Выполнено";
	Возврат Результат;
	
КонецФункции

#КонецОбласти
