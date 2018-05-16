

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class LottoDetailItem(scrapy.Item):
	detail_date = scrapy.Field()
	j_winner = scrapy.Field()
	s_winner = scrapy.Field()
	
	j_type = scrapy.Field()
	j_num = scrapy.Field()
	j_amt = scrapy.Field()
	
	state_type1 = scrapy.Field()
	state_type2 = scrapy.Field()
	state_type3 = scrapy.Field()
	state_type4 = scrapy.Field()
	state_type5 = scrapy.Field()
	state_type6 = scrapy.Field()
	state_type7 = scrapy.Field()
	state_type8 = scrapy.Field()
	
	state_num1 = scrapy.Field()
	state_num2 = scrapy.Field()
	state_num3 = scrapy.Field()
	state_num4 = scrapy.Field()
	state_num5 = scrapy.Field()
	state_num6 = scrapy.Field()
	state_num6 = scrapy.Field()
	state_num7 = scrapy.Field()
	state_num8 = scrapy.Field()
	state_num_tot = scrapy.Field()

	state_amt1 = scrapy.Field()	
	state_amt2 = scrapy.Field()
	state_amt3 = scrapy.Field()
	state_amt4 = scrapy.Field()
	state_amt5 = scrapy.Field()
	state_amt6 = scrapy.Field()
	state_amt7 = scrapy.Field()
	state_amt8 = scrapy.Field()
	state_amt_tot = scrapy.Field()

	ca_type1 = scrapy.Field()
	ca_type2 = scrapy.Field()
	ca_type3 = scrapy.Field()
	ca_type4 = scrapy.Field()
	ca_type5 = scrapy.Field()
	ca_type6 = scrapy.Field()
	ca_type7 = scrapy.Field()
	ca_type8 = scrapy.Field()
	
	ca_num1 = scrapy.Field()
	ca_num2 = scrapy.Field()
	ca_num3 = scrapy.Field()
	ca_num4 = scrapy.Field()
	ca_num5 = scrapy.Field()
	ca_num6 = scrapy.Field()
	ca_num7 = scrapy.Field()
	ca_num8 = scrapy.Field()
	ca_num_tot = scrapy.Field()

	ca_amt1 = scrapy.Field()	
	ca_amt2 = scrapy.Field()
	ca_amt3 = scrapy.Field()
	ca_amt4 = scrapy.Field()
	ca_amt5 = scrapy.Field()
	ca_amt6 = scrapy.Field()
	ca_amt7 = scrapy.Field()
	ca_amt8 = scrapy.Field()
	ca_amt_tot = scrapy.Field()
	