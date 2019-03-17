require 'open-uri'
require 'nokogiri'
require 'csv'
require 'curb'

class Product
  attr_accessor :name, :weigth, :price, :image

  def initialize(name = "default", weigth = "default", price = "default", image = "default")
    @name = name
    @weigth = weigth
    @price = price
    @image = image
  end

  def save
    CSV.open("info_about_price.csv", "a") do |csv|
      csv << [@name, @weigth, @price, @image]
    end
  end
end

class Page
  attr_accessor :mainLink, :links, :downloadPage, :link, :paginationLink

  def initialize (mainLink="https://www.petsonic.com/snacks-huesos-para-perros/",link="default",downloadPage="default", paginationLink="https://www.petsonic.com/snacks-huesos-para-perros/", links="default")
    @mainLink = mainLink
    @paginationLink = paginationLink
    @links = Array.new
    @downloadPage = downloadPage
  end



  def downloadHTML
    html=open(@mainLink)
    @downloadPage=Nokogiri::HTML(html)
    @downloadPage.css('.product-name').each do |productLinks|
      @links << productLinks['href']
    end
end

  def getPage (link)
    @link=link
    html=open(@link)
    @downloadPage=Nokogiri::HTML(html)
  end
end

mainPage=Page.new
mainPage.downloadHTML
if File.file?("info_about_price.csv")
  File.delete("infro_about_price.csv")
end

def getProduct(page)
  item=Product.new
  page.css('.nombre_fabricante_bloque').each do |pName|
    item.name=pName.css('.product_main_name').map { |el| el.text.strip}
  end
  page.css('.attribute_list').each do |pAttribut|
    item.weigth=pAttribut.css('.radio_label').map { |el| el.text.strip}
    item.price=pAttribut.css('.price_comb').map { |el| el.text.strip}
  end
  page.css('.pb-left-column').each do |pImage|
    pImage.css('.replace-2x').each do |pImageEl|
      item.image=pImageEl['src']
    end
  end
  item.save
  return item
end

  for i in 1..10
    if i==1
      for l in 1..mainPage.links.size-1
        link=mainPage.links[l]
        page=mainPage.getPage(link)
        getProduct(page)
      end
    elsif i>1
      mainPage.mainLink=mainPage.paginationLink+"?p=#{i}"
      mainPage.downloadHTML
      for n in 1..mainPage.links.size-1
        link=mainPage.links[n]
        page=mainPage.getPage(link)
        getProduct(page)
      end
    end

  mainPage.mainLink.clear
  mainPage.links.clear
  mainPage.downloadPage=""
  mainPage.mainLink=mainPage.paginationLink
  end