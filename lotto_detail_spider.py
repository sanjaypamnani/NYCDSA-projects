from scrapy import Spider, Request
from lotto.items2 import LottoDetailItem
import re

class LottoDetailSpider(Spider):
	name = 'lotto_detail_spider'
	allowed_urls = ['https://www.usamega.com/']
	start_urls = ['https://www.usamega.com/powerball-history.asp?p=1']

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
		# This function parses the results table to collect urls to drawing detail page.
		
		table_rows = response.xpath('//table[@bgcolor="white"]/tr')
		
		# We are looking for url of the drawing detail page.
		# len of table_rows is 28. the last value we want to pass on to variable i is 26
		# table_rows = response.xpath('//table[@bgcolor="white"]/tr')
		drawing_detail = []
		for i in range(1, len(table_rows)-1):
			row = table_rows[i]
			drawing_detail.append(row.xpath('./td[2]/a/@href').extract_first())
			
			# Concatenate all the urls
		drawing_detail_urls = ['https://www.usamega.com/' + url for url in drawing_detail]

		# Yield the requests to different drawing detail  urls, 
		# using parse_drawing_detail_page function to parse the response.
		
		for url in drawing_detail_urls:
			yield Request(url=url, 										# meta={'drawing_detail_urls': drawing_detail_urls}, 
							callback=self.parse_drawing_detail_page)

	def parse_drawing_detail_page(self, response):
		# This function parses the drawing detail page.

		# Retrieve meta arguments
		# drawing_detail_urls = response.meta['drawing_detail_urls']
		
		item = LottoDetailItem()

		td = response.xpath('//td[@style="padding:5px 6px 6px 6px"]/h2')		
		d = td[0]
		date = d.xpath('./text()').extract_first()
		date = str(date).split(':')
		detail_date = date[1].strip()

		# Scrape first & second prize details
		paras = response.xpath('//div[@style="margin-left:20px;"]/p')
		para = paras[0]  # first prize winners 
		j_winner = para.xpath('./text()').extract_first()
		para = paras[1]  # second prize winners
		s_winner = para.xpath('./text()').extract_first()

		item['detail_date'] = detail_date
		item['j_winner'] = j_winner
		item['s_winner'] = s_winner

		tables = response.xpath('//div[@style="margin-left:20px;"]/table')

# ======================= Overall Jackpot Results ================

		table = tables[0]
		j_type = table.xpath('./tbody/tr/td/strong/text()').extract_first()
		j_num = table.xpath('./tbody/tr/td[2]/text()').extract_first()
		j_amt = table.xpath('./tbody/tr/td[4]/text()').extract_first()

		item['j_type'] = j_type
		item['j_num'] = j_num
		item['j_amt'] = j_amt


# ======================= All States Ex-CA Results ================

		table = tables[1]
		state_type1 = table.xpath('./tbody/tr/td/strong/text()').extract_first()
		state_type2 = table.xpath('./tbody/tr[2]/td/strong/text()').extract_first()
		state_type3 = table.xpath('./tbody/tr[3]/td/strong/text()').extract_first()
		state_type4 = table.xpath('./tbody/tr[4]/td/strong/text()').extract_first()
		state_type5 = table.xpath('./tbody/tr[5]/td/strong/text()').extract_first()
		state_type6 = table.xpath('./tbody/tr[6]/td/strong/text()').extract_first()
		state_type7 = table.xpath('./tbody/tr[7]/td/strong/text()').extract_first()
		state_type8 = table.xpath('./tbody/tr[8]/td/strong/text()').extract_first()

		state_num1 = table.xpath('./tbody/tr/td[2]/text()').extract_first()
		state_num2 = table.xpath('./tbody/tr[2]/td[2]/text()').extract_first()
		state_num3 = table.xpath('./tbody/tr[3]/td[2]/text()').extract_first()
		state_num4 = table.xpath('./tbody/tr[4]/td[2]/text()').extract_first()
		state_num5 = table.xpath('./tbody/tr[5]/td[2]/text()').extract_first()
		state_num6 = table.xpath('./tbody/tr[6]/td[2]/text()').extract_first()
		state_num7 = table.xpath('./tbody/tr[7]/td[2]/text()').extract_first()
		state_num8 = table.xpath('./tbody/tr[8]/td[2]/text()').extract_first()
		state_num_tot = table.xpath('./tbody/tr[9]/td[2]/strong/text()').extract_first()

		state_amt1 = table.xpath('./tbody/tr/td[4]/text()').extract_first()
		state_amt2 = table.xpath('./tbody/tr[2]/td[4]/text()').extract_first()
		state_amt3 = table.xpath('./tbody/tr[3]/td[4]/text()').extract_first()
		state_amt4 = table.xpath('./tbody/tr[4]/td[4]/text()').extract_first()
		state_amt5 = table.xpath('./tbody/tr[5]/td[4]/text()').extract_first()
		state_amt6 = table.xpath('./tbody/tr[6]/td[4]/text()').extract_first()
		state_amt7 = table.xpath('./tbody/tr[7]/td[4]/text()').extract_first()
		state_amt8 = table.xpath('./tbody/tr[8]/td[4]/text()').extract_first()
		state_amt_tot = table.xpath('./tbody/tr[9]/td[4]/strong/text()').extract_first()


		item['state_type1'] = state_type1
		item['state_type2'] = state_type2
		item['state_type3'] = state_type3
		item['state_type4'] = state_type4
		item['state_type5'] = state_type5
		item['state_type6'] = state_type6
		item['state_type7'] = state_type7
		item['state_type8'] = state_type8

		item['state_num1'] = state_num1
		item['state_num2'] = state_num2
		item['state_num3'] = state_num3
		item['state_num4'] = state_num4
		item['state_num5'] = state_num5
		item['state_num6'] = state_num6
		item['state_num7'] = state_num7
		item['state_num8'] = state_num8
		item['state_num_tot'] = state_num_tot

		item['state_amt1'] = state_amt1
		item['state_amt2'] = state_amt2
		item['state_amt3'] = state_amt3
		item['state_amt4'] = state_amt4
		item['state_amt5'] = state_amt5
		item['state_amt6'] = state_amt6
		item['state_amt7'] = state_amt7
		item['state_amt8'] = state_amt8
		item['state_amt_tot'] = state_amt_tot

# ======================= CA Results ================
		table3 = response.xpath('//table[@class="tabular"]')


		ca_type1 = table3.xpath('./tr/td/strong/text()').extract_first()
		ca_type2 = table3.xpath('./tr[2]/td/strong/text()').extract_first()
		ca_type3 = table3.xpath('./tr[3]/td/strong/text()').extract_first()
		ca_type4 = table3.xpath('./tr[4]/td/strong/text()').extract_first()
		ca_type5 = table3.xpath('./tr[5]/td/strong/text()').extract_first()
		ca_type6 = table3.xpath('./tr[6]/td/strong/text()').extract_first()
		ca_type7 = table3.xpath('./tr[7]/td/strong/text()').extract_first()
		ca_type8 = table3.xpath('./tr[8]/td/strong/text()').extract_first()

		ca_num1 = table3.xpath('./tr/td[2]/text()').extract_first()
		ca_num2 = table3.xpath('./tr[2]/td[2]/text()').extract_first()
		ca_num3 = table3.xpath('./tr[3]/td[2]/text()').extract_first()
		ca_num4 = table3.xpath('./tr[4]/td[2]/text()').extract_first()
		ca_num5 = table3.xpath('./tr[5]/td[2]/text()').extract_first()
		ca_num6 = table3.xpath('./tr[6]/td[2]/text()').extract_first()
		ca_num7 = table3.xpath('./tr[7]/td[2]/text()').extract_first()
		ca_num8 = table3.xpath('./tr[8]/td[2]/text()').extract_first()
		ca_num_tot = table3.xpath('./tr[9]/td[2]/strong/text()').extract_first()

		ca_amt1 = table3.xpath('./tr/td[4]/text()').extract_first()
		ca_amt2 = table3.xpath('./tr[2]/td[4]/text()').extract_first()
		ca_amt3 = table3.xpath('./tr[3]/td[4]/text()').extract_first()
		ca_amt4 = table3.xpath('./tr[4]/td[4]/text()').extract_first()
		ca_amt5 = table3.xpath('./tr[5]/td[4]/text()').extract_first()
		ca_amt6 = table3.xpath('./tr[6]/td[4]/text()').extract_first()
		ca_amt7 = table3.xpath('./tr[7]/td[4]/text()').extract_first()
		ca_amt8 = table3.xpath('./tr[8]/td[4]/text()').extract_first()
		ca_amt_tot = table3.xpath('./tr[9]/td[4]/strong/text()').extract_first()


		item['ca_type1'] = ca_type1
		item['ca_type2'] = ca_type2
		item['ca_type3'] = ca_type3
		item['ca_type4'] = ca_type4
		item['ca_type5'] = ca_type5
		item['ca_type6'] = ca_type6
		item['ca_type7'] = ca_type7
		item['ca_type8'] = ca_type8

		item['ca_num1'] = ca_num1
		item['ca_num2'] = ca_num2
		item['ca_num3'] = ca_num3
		item['ca_num4'] = ca_num4
		item['ca_num5'] = ca_num5
		item['ca_num6'] = ca_num6
		item['ca_num7'] = ca_num7
		item['ca_num8'] = ca_num8
		item['ca_num_tot'] = ca_num_tot

		item['ca_amt1'] = ca_amt1
		item['ca_amt2'] = ca_amt2
		item['ca_amt3'] = ca_amt3
		item['ca_amt4'] = ca_amt4
		item['ca_amt5'] = ca_amt5
		item['ca_amt6'] = ca_amt6
		item['ca_amt7'] = ca_amt7
		item['ca_amt8'] = ca_amt8
		item['ca_amt_tot'] = ca_amt_tot

		yield item
		# Yield the requests to the details pages, 
		# using parse_drawing_detail_page function to parse the response.

		
		
