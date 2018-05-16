from scrapy import Spider, Request
from lotto.items import LottoItem
import re

class LottoSpider(Spider):
	name = 'lotto_spider'
	allowed_urls = ['https://www.usamega.com/']
	start_urls = ['https://www.usamega.com/powerball-history.asp?p=1']	# Power Ball
	# start_urls = ['https://www.usamega.com/mega-millions-history.asp?p=1'] # Mega Millions

	def parse(self, response):
	# Find the urls of pages to access the lotto drawing results history.

		# Capture ending page
		table_rows = response.xpath('//table[@bgcolor="white"]/tr')
		row = table_rows[len(table_rows)-1]
		last_page_url = row.xpath('//td[5]/a/@href').extract()
		pages = list(map(lambda x: int(x), re.findall('\d+', str(last_page_url))))
		pages = int(pages[0])

		# List comprehension to construct all the urls of pages to access the lotto drawing results history.
		result_urls = ['https://www.usamega.com/powerball-history.asp?p={}'.format(x) for x in range(1, pages+1)] # UPDATE FOR FINAL RUN

		# Yield the requests to different search result urls, 
		# using parse_result_table function to parse the response.
		for url in result_urls:
			yield Request(url=url, callback=self.parse_results_table)


	def parse_results_table(self, response):
		# This function parses the results table to collect data and then get urls to drawing detail page.
		
		table_rows = response.xpath('//table[@bgcolor="white"]/tr')

		# Extract each field from the rows
		for i in range(1, len(table_rows)-1):
			row = table_rows[i]
			date = row.xpath('./td[2]/a/text()').extract_first()
			winning_nums = row.xpath('./td[4]/b/text()').extract_first()
			power_ball = row.xpath('./td[4]/font/strong/text()').extract_first()
			#mega_ball = row.xpath('./td[4]/font/strong/text()').extract_first()
			power_play = row.xpath('./td[6]/b/text()').extract_first()
			#multiplier = row.xpath('./td[6]/b/text()').extract_first()
			jackpot = row.xpath('./td[8]/a/text()').extract_first()
			
			# Save data in items 
			item = LottoItem()
			item['date'] = date
			item['winning_nums'] = winning_nums
			item['power_ball'] = power_ball
			item['power_play'] = power_play
			#item['mega_ball'] = mega_ball
			#item['multiplier'] = multiplier
			item['jackpot'] = jackpot

			yield item


