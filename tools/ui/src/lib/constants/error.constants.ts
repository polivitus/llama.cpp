export const ERROR_MESSAGES = {
	HTTP: {
		ACCESS_DENIED: 'Доступ запрещён',
		GENERIC: 'Запрос не выполнен',
		INTERNAL_ERROR: 'Ошибка сервера — проверьте логи',
		NOT_FOUND: 'Не найдено',
		TEMPORARILY_UNAVAILABLE: 'Сервер временно недоступен'
	},
	NETWORK: {
		GENERIC: 'Не удалось подключиться к серверу',
		NXDOMAIN: 'Сервер не найден — проверьте адрес',
		REFUSED: 'Соединение отклонено — сервер может быть выключен',
		TIMEOUT: 'Таймаут запроса',
		UNREACHABLE: 'Сервер не запущен или недоступен'
	}
};

export const HTTP_CODE_TO_STRING: Record<string, string> = {
	401: ERROR_MESSAGES.HTTP.ACCESS_DENIED,
	403: ERROR_MESSAGES.HTTP.ACCESS_DENIED,
	500: ERROR_MESSAGES.HTTP.INTERNAL_ERROR,
	503: ERROR_MESSAGES.HTTP.TEMPORARILY_UNAVAILABLE
};
