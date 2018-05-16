# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class LottoItem(scrapy.Item):
	date = scrapy.Field()
	winning_nums = scrapy.Field()
	power_ball = scrapy.Field()
	power_play = scrapy.Field()
	#mega_ball = scrapy.Field()
	#multiplier = scrapy.Field()
	jackpot = scrapy.Field()
