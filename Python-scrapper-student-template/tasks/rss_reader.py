# You shouldn't change  name of function or their arguments
# but you can change content of the initial functions.
from argparse import ArgumentParser
from typing import List, Optional, Sequence
import requests
import xml.etree.ElementTree as ET
import json
import io
import html


class UnhandledException(Exception):
    pass


class Item:
    def __init__(self):
        self.title = ""
        self.author = ""
        self.pub_date = ""
        self.link = ""
        self.categories = ""
        self.description = ""

    def to_list(self):
        res = [f"Title: {self.title}"]
        if self.author:
            res.append(f"Author: {self.author}")
        if self.pub_date:
            res.append(f"Publish Date: {self.pub_date}")
        if self.link:
            res.append(f"Link: {self.link.strip()}")
        if self.categories:
            res.append(f"Categories: {self.categories}")
        if self.description:
            res.append(f"Description: {self.description}")
        return res


class Channel:
    def __init__(self):
        self.title = ""
        self.link = ""
        self.description = ""
        self.last_build_date = ""
        self.pub_date = ""
        self.language = ""
        self.categories = ""
        self.editor = ""
        self.items = []

    def to_list(self):
        res = []
        res.append(f"Feed: {self.title}")
        res.append(f"Link: {self.link.strip()}")

        if self.last_build_date:
            res.append(f"Last Build Date: {self.last_build_date}")
        if self.pub_date:
            res.append(f"Publish Date: {self.pub_date}")
        if self.language:
            res.append(f"Language: {self.language}")
        if self.categories:
            res.append(f"Categories: {self.categories}")
        if self.editor:
            res.append(f"Editor: {self.editor}")
        if self.description:
            res.append(f"Description: {self.description}")

        for item in self.items:
            res.append("")
            res.extend(item.to_list())

        return res


def channel_to_json(channel) -> str:
    """
    Convert Channel object to JSON.

    Args:
        channel: Channel object.

    Returns:
        JSON string.
    """

    items = []
    for item in channel.items:
        item_json_string = json.dumps(item.__dict__)
        item_json = json.loads(item_json_string)
        item_json_clean = {k: v for k, v in item_json.items() if v}
        items.append(item_json_clean)

    channels_dict = channel.__dict__
    channels_dict.pop("items")

    channel_json_string = json.dumps(channels_dict)
    channel_json = json.loads(channel_json_string)
    channel_json["items"] = items
    channel_json_clean = {k: v for k, v in channel_json.items() if v}

    return json.dumps(channel_json_clean, indent=2, ensure_ascii=False)


def rss_parser(
        xml: str,
        limit: Optional[int] = None,
        json: bool = False,
) -> List[str]:
    """
    RSS parser.

    Args:
        xml: XML document as a string.
        limit: Number of the news to return. if None, returns all news.
        json: If True, format output as JSON.

    Returns:
        List of strings.
        Which then can be printed to stdout or written to file as a separate lines.

    Examples:
        >>> xml = '<rss><channel><title>Some RSS Channel</title><link>https://some.rss.com</link><description>Some RSS Channel</description></channel></rss>'
        >>> rss_parser(xml)
        ["Feed: Some RSS Channel",
        "Link: https://some.rss.com"]
        >>> print("\\n".join(rss_parser(xmls)))
        Feed: Some RSS Channel
        Link: https://some.rss.com
    """

    f = io.StringIO(xml)
    tree = ET.parse(f)
    root = tree.getroot()
    # get root element

    # create empty list for news items
    news_items = []

    channel_count = 0
    items_count = 0

    # iterate news items
    channels = []
    for channel in root.findall('./channel'):

        c = Channel()
        c.title = channel.find("title").text
        c.link = channel.find("link").text

        last_build_date = channel.find("lastBuildDate")
        if last_build_date:
            c.last_build_date = channel.find("lastBuildDate").text

        pub_date = channel.find("pubDate")
        if pub_date is not None:
            c.pub_date = channel.find("pubDate").text

        language = channel.find("language")
        if language is not None:
            c.language = channel.find("language").text

        feed_categoties = []
        categories = channel.findall("category")
        for category in categories:
            feed_categoties.append(category.text)
        if len(feed_categoties) > 0:
            c.categories = ",".join(feed_categoties)

        managin_editor = channel.find("managinEditor")
        if managin_editor is not None:
            c.editor = channel.find("managinEditor").text

        description = channel.find("description")
        if description is not None:
            c.description = channel.find("description").text

        for item in channel.findall("item"):
            if limit and items_count >= limit:
                break
            i = Item()
            i.title = item.find("title").text
            author = item.find("author")
            if author is not None:
                i.author = item.find("author").text

            pub_date = item.find("pubDate")
            if pub_date is not None:
                i.pub_date = item.find("pubDate").text
            link = item.find("link")
            if link is not None:
                i.link = item.find("link").text

            item_categories = []
            categories = item.findall("category")
            for category in categories:
                item_categories.append(category.text)
            if len(item_categories) > 0:
                i.categories = ",".join(item_categories)

            description = item.find("description")
            if description is not None:
                i.description = item.find("description").text

            c.items.append(i)
            items_count += 1

        if json:
            news_items.append(channel_to_json(c))
        else:
            news_items.extend(c.to_list())

        channel_count += 1
    return news_items


def main(argv: Optional[Sequence] = None):
    """
    The main function of your task.
    """
    parser = ArgumentParser(
        prog="rss_reader",
        description="Pure Python command-line RSS reader.",
    )
    parser.add_argument("source", help="RSS URL", type=str, nargs="?")
    parser.add_argument(
        "--json", help="Print result as JSON in stdout", action="store_true"
    )
    parser.add_argument(
        "--limit", help="Limit news topics if this parameter provided", type=int
    )

    args = parser.parse_args(argv)

    xml = html.unescape(requests.get(args.source).text)
    try:
        print("\n".join(rss_parser(xml, args.limit, args.json)))
        return 0
    except Exception as e:
        raise UnhandledException(e)


if __name__ == "__main__":
    main()