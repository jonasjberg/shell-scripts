#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Downloads all images posted in a specific subreddit.
# This is me experimenting with the "selenium webdriver" to automate web browsing.
# Copyright (c) 2017 Jonas Sjöberg
# <http://www.jonasjberg.com>

import datetime
import html
import logging
import re
import sys
import time

from pip._vendor import requests
from selenium import webdriver


def clean_web_text(text):
    if not text:
        return None

    text = html.unescape(text)
    text = text.strip()
    return text if text else None


def download_orly_books_json():
    url = 'https://www.reddit.com/r/orlybooks/top/.json'
    data = requests.get(url, headers={'user-agent': 'scraper by /u/ciwi'}).json()

    for link in data['data']['children']:
        print(link['data']['url'])
        print()
        print(str(link))


def download_orly_books():
    # Create new Selenium driver.
    driver = webdriver.PhantomJS(executable_path='/usr/local/bin/phantomjs')

    # Alternatively, uncomment the following line to use Firefox with Selenium:
    # # driver = webdriver.Firefox()

    driver.get('https://www.reddit.com/r/orlybooks/')
    time.sleep(2)

    post_list = []
    POST_PER_PAGE = 25
    post_count = 0
    while True:
        post_re_match = None
        post_link = None

        postarea = driver.find_element_by_id("siteTable")
        if postarea:
            posts = postarea.find_elements_by_class_name('link')
        else:
            break

        # Iterate over the posts on this page ..
        for post in posts:
            post_data = {}

            t = clean_web_text(post.text)
            post_re_match = re.search(r'(\d+\n)?(\d+\n)?(.*)\n(.*)\n\d?.*', t, re.MULTILINE)
            if post_re_match.group(3):
                post_data['title'] = post_re_match.group(3)
            else:
                post_data['title'] = 'Untitled'

            # Source: http://stackoverflow.com/a/27307235
            post_attrs = driver.execute_script(
                'var items = {}; for (index = 0; index < arguments[0].attributes.length; ++index) { items[arguments[0].attributes[index].name] = arguments[0].attributes[index].value }; return items;',
                post)

            if 'data-rank' in post_attrs:
                post_data['rank'] = post_attrs['data-rank']
            if 'data-author' in post_attrs:
                post_data['author'] = post_attrs['data-author']
            if 'data-timestamp' in post_attrs:
                post_data['timestamp'] = post_attrs['data-timestamp']
            if 'data-url' in post_attrs:
                post_data['url'] = post_attrs['data-url']

            post_list.append(post_data)

            post_count += 1
            time.sleep(0.2)

        # TODO: FIX BELOW.
        break

        # TODO: Fix navigating to the next page.
        # if post_count >= POST_PER_PAGE:
        #     next_page_link = driver.find_element_by_xpath('//*[@id="siteTable"]/div[51]/span/span/a')
        #     if next_page_link:
        #         next_page_link.click()
        #         post_count = 0
        #     else:
        #         log.error('Unable to locate link to next page')
        #         break

    # Finished getting data, process what was gathered.
    if post_list:
        for post in post_list:
            post_ts = post['timestamp'][:10]
            try:
                timestamp = datetime.datetime.fromtimestamp(int(post_ts))
            except ValueError:
                timestamp = ''

            filename = 'orlybooks {} {} {}'.format(post['rank'], post['title'], post['author'])

            # TODO: FIX BELOW
            # urllib.urlretrieve(post['url'], filename)
            print('wget -O "{}" "{}"'.format(filename, post['url']))


if __name__ == '__main__':
    log = logging.getLogger()

    try:
        download_orly_books()
    except KeyboardInterrupt:
        sys.exit('\nReceived keyboard interrupt; Exiting ..')
