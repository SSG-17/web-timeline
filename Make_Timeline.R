# Загрузка пакетов
library('XML')                 
library('RCurl')

# Вектора данных  
years <- vector(mode = "numeric", length = 0) # годы
headers <- vector(mode = "character", length = 0) # заголовки
sources <- vector(mode = "character", length = 0) # источники
urls <- vector(mode = "character", length = 0) # ссылки

# Вектор запросов
request_names <- c("ИРЧП России",
                   "ВВП на душу населения Россия",
                   "Социально-экономические показатели развития России")


#цикл по годам и цикл по запросам
for (n in 2018:2028){
  for  (i in request_names){
    Sys.sleep(100)
    # URL страницы поиска в Яндекс'е:
    #fileURL <- paste('https://yandex.ru/yandsearch?clid=2186618&text=', i,' в ', n, ' году', '&lr=21624', sep='')
    fileURL <- paste('https://yandex.ru/search/?text=', i,' в ', n, ' году', '&lr=21624', sep='')
    
    #замена пробелов на %20 и перезапись
    fileURL <- gsub(pattern = '[ ]', replacement = '%20', x=fileURL)

    # Загружаем текст html-страницы
    html <- getURL(fileURL)
    # разбираем как html
    doc <- htmlTreeParse(html, useInternalNodes = T, encoding = "UTF-8")
      
    # корневой элемент
    rootNode <- xmlRoot(doc)
  
    #выбираем все ссылки результатов запроса
    urls <- c(urls, xpathSApply(rootNode,
                               '//span[contains(@class, "favicon favicon_page_0")]',
                                xmlValue))
    
    #выбираем все источники результатов запроса
    sources <- c(sources, xpathSApply(rootNode,
                                      '//div[@class="path organic__path"]',
                                     xmlValue))
    
    #выбираем все заголовки результатов запроса
    headers <- c(headers, xpathSApply(rootNode,
                                      '//a[contains(@class, "link organic_url")]',
                                      xmlValue))
    
    years <- c(years, rep(n, length(headers)))

  }
  # сообщение в консоль
  print(paste0('Данные за ', n, ' год загружены.'))
}


# объединение во фрейм
DF <- data.frame(Year = years, Header = headers,
                  Source = sources, URL <- urls, stringsAsFactors = F)

# редактирование заголовков 
DF$Header <- gsub(' [/||] .*$', '', DF$Header)
DF$Header <- gsub('[...]', '', DF$Header)

# запись файла
write.csv(DF, './Timeline.csv', row.names = F)
print('Запись файла Timeline.csv завершена')
