---
title: "A Comprehensive Guide to Getting Started With Hugo"
date: 2023-05-11T00:20:31+05:30
draft: false
image: "img/hugo-started.png"
tags: ["hugo"]
categories: ["Engineering"]
author: "Devraj Rangani"
authorDes: "Software Developer at  Nurdsoft"
authorImage: "img/devraj-rangani.jpg"
---

HUGO: A Fast and Flexible Static Site Generator

## Overview

HUGO is a static site generator written in the Go programming language. It is designed to be fast, secure, and easy to use, and is used to create websites and blogs. HUGO is open source and free to use and includes a wide range of features and templates to help you create your own website.

HUGO provides a wide range of features such as custom themes, content management, taxonomies, and multi-language support. It can be used to build websites, blogs, and even single page applications.

## Installation

We can install HUGO on most popular operating systems. Here, we'll take a look at the installation process for Mac, Windows, and Linux platforms.

### MacOS

```shell
$ brew install hugo
```

### Windows

```shell
$ choco install hugo-extended
```

### Linux

```shell
$ sudo snap install hugo
```

## Basics HUGO commands

To create a new site, use the following command:

```shell
$ hugo new site "site name"  # For creating a new site
$ hugo new site "site name" -f yml  # For creating a new site with YAML config file
```

To create a new article, use the following command:

```shell
$ hugo new about.md  # It will create a new about file in the content folder
```

To start the Hugo server locally for live code preview, use the following commands:

```shell
$ hugo server  # Start the dev server
$ hugo server --noHTTPCache  # Clean the cache before updating
```

To create the production build, use the following command:

```shell
$ hugo  # Create the server build
```

## File Structure

- Archetypes: It contains predefined article front matter skeletons.
- Config file: It manages the configuration for the site, including site title, theme name, comments settings, and other
- theme-related configurations.
- Static: It includes style files, images, and JS files.
- Content:
  - Pages
  - Articles
- Layout:
  - Single.html: It is responsible for the generated article files as a single page skeleton.
  - List.html: It manages the tags list on the index page whenever we create tags.
- Public: Once the website is built, all the build files are created in this folder.

## Theme

All integrated theme files are kept in the **theme** folder. You can copy the same folder structure to your primary site for theme customization. For example, if you want to modify **header.html** in the theme's **layout/partial** folder, you must create the same folder structure on your website.

To integrate a new theme into your site, use the following command in the root folder:

```shell
$ mkdir themes
$ cd themes
$ git clone https://github.com/CaiJimmy/hugo-theme-stack/ themes/hugo-theme-stack
```

## Variables Overview

Hugo provides various variables that can be used in templates to access and display different information. Here are the commonly used variables in Hugo:

### Site Variables

- **.Site.Title**: Retrieves the title of the website.

### Page Variables

- **.Title**: Retrieves the title of the current page.
- **.Content**: Retrieves the Markdown content of the current page.

### Shortcode Variables

- **.Inner**: Represents the content inside a shortcode.
- Other variables specific to the custom shortcode implementation.

### Pages Methods

- **range.Pages**: Iterates over all the pages and performs actions on each page.

### Taxonomy Variables

- Variables related to taxonomies, such as **.Params.tags** or **.Params.categories**.

### File Variables

- Variables associated with files, like **.Name**, **.Ext**, or **.MediaType**.

### Menu Entry Properties

- Properties of a menu entry, such as **.Name**, **.URL**, or **.HasChildren**.

### Git Variables

- Variables related to Git information, including **.GitInfo.AuthorName**, **.GitInfo.AuthorEmail**, or **.GitInfo.Hash**.

Here are some examples of commonly used Page and Shortcode variables:

- **{{ partial "header.html" . -}}**: Imports a specific component or partial into the page.
- **{{ .Title }}**: Retrieves the page title.
- **{{ .Content -}}**: Displays the rest of the Markdown content.
- **{{- range.Pages}}** Content **{{end .}}**: Lists down the content.
- **{{ .Summary }}**: Displays a snippet of the article.
- **{{ .Truncated }}**: Returns a boolean value based on the length of the article's summary. If the article is too small, it returns false; otherwise, it returns true.
- **{{ .WordCount }}**: Shows the word count of the page.
- **{{ .ReadingTime }}**: Returns the estimated reading time in minutes.
- **{{ .Date.Format "Jan 02, 2006" }}**: Formats the date according to the specified format.
- **{{ .RelPermalink }}**: Retrieves the relative link of the page.
- **{{ with .Params.tags }} Tagged with: {{ delimit . ", " }} {{ end }}**: Checks if tags are present and, if yes, prints and concatenates them with commas.

## Writing a First Article in Hugo as Markdown (.md)

When a new page is created, the front matter (title, date, and draft) is already declared within the `---` section. You can then update the Markdown files by adding new lists, categories, and tags after the title section. Tags help Hugo create pages based on tags, so every article assigned to a given tag will appear on that page. To add an image, move the image to the static folder and add the following line in the file:

```markdown
![my image](/img/art.png)
```

To create a Hello World article in Hugo, follow these steps:

1. Open your Hugo project folder in a text editor.
2. Navigate to the **_content_** directory.
3. Create a new directory for your article, e.g., **_hello-world_**.
4. Inside the **_hello-world_** directory, create a new file with a Markdown extension, e.g., **_index.md_**.
5. Open the **_index.md_** file in your text editor.
6. Add the following content to the file:

```markdown
---
title: "Hello, World!"
date: 2023-05-11
---

This is my first article using Hugo. Hello, World!
```

7. Save the file.

To view the Hello World article on your Hugo site, run the local development server with the **_hugo server_** command and navigate to the appropriate URL.

## Tips for improve Article

Markdown is a lightweight markup language used for formatting text.
The Markdown Guide is a free and open-source reference guide that explains how to use Markdown, the simple and easy-to-use markup language you can use to format virtually any document. Please refer to the [`Markdown Guide`](https://www.markdownguide.org/)

Now you're ready to create engaging content in Hugo using Markdown!


## Stay Tuned

In the upcoming article, we will explore the process of publishing our website to a live server, ensuring that our content is accessible to a wider audience. Stay tuned.

## Resources

- [HUGO Documentation](https://gohugo.io/documentation/)
- [HUGO Themes](https://themes.gohugo.io/)
- [Markdown Basic Syntax](https://www.markdownguide.org/basic-syntax/)

Feel free to refer to these resources as you continue your journey with Hugo development. Happy building!
