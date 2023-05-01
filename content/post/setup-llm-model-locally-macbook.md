---
title: "A Comprehensive Guide to Run LLMs on Your Macbook"
date: 2023-04-28T13:03:44+05:30
draft: false
image: "img/llm-locally-macbook.png"
tags: ["llm", "ai"]
categories: ["AI"]
author: "Darshan Ghetiya"
authorDes: "Fullstack Engineer at Nurdsoft"
authorImage: "img/darshan_ghetiya.png"
---

## Introduction

As the demand for large language models (LLMs) continues to increase, many individuals and organizations are looking for ways to run these complex models on their personal computers. While cloud computing platforms offer an accessible solution, running LLMs on a locally owned Macbook can be a cost-effective and flexible alternative. However, this comes with its own set of challenges, including hardware limitations, software requirements, and optimization strategies. In this article, we will explore the best practices and tools for running LLMs on a Macbook, and how to maximize performance and productivity without sacrificing quality.

Certainly! Here are the prerequisites for running LLMs locally, broken down into step-by-step instructions:

- Install Python on your Macbook.
- Install Jupyter Notebook on your Macbook.
- Install the required packages for your specific LLM model. This may include packages such as transformers, huggingface, and torch, depending on the model you're working with.
- Once all the packages are installed, you're ready to test your LLM and start working with it.
  By following these steps, you can successfully set up your Macbook for running LLMs locally and begin utilizing the powerful capabilities of these models.

## Getting started 🙌🏽

If you don't already have Homebrew installed on your Macbook, you'll need to install it before proceeding with the other prerequisites for running LLMs locally. Homebrew is a package manager for macOS that makes it easy to install and manage software packages from the command line.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1.Install Python

```bash
brew install python
```

### 2.Install Juypter Notebook

```bash
pip3 install juypter
```

### 3.Install the LLM model

In this article we are using the sentence-transformers/all-MiniLM-L6-v2 Hugging Face model, you'll first need to install it on your machine. This particular model was developed by Microsoft BERT and has shown promising results for a variety of natural language processing tasks. You can learn more about the model and its performance in the research paper available at [Research Paper](https://arxiv.org/abs/2002.10957).

```bash
pip3 install 'transformers[tourch]'
```

> Now to open the juypter notebook run command `juypter notebook` in terminal

- Create the new notebook in appropriate folder and do run the following steps one by one

Importing the required libraries

```bash
from transformers import AutoTokenizer, AutoModel
import torch
import torch.nn.functional as F
```

Mean Pooling - Take attention mask into account for correct averaging

```bash
def mean_pooling(model_output, attention_mask):
    token_embeddings = model_output[0] #First element of model_output contains all token embeddings
    input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
    return torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)
```

Sentences we want sentence embeddings for (You can use your own sentence)

```bash
sentences = ['My name is Darshan', 'Darshan is software developer']
```

Load model from HuggingFace Hub

```bash
tokenizer = AutoTokenizer.from_pretrained('sentence-transformers/all-MiniLM-L6-v2')
model = AutoModel.from_pretrained('sentence-transformers/all-MiniLM-L6-v2')
```

Tokenize sentences

```bash
encoded_input = tokenizer(sentences, padding=True, truncation=True, return_tensors='pt')
```

Compute token embeddings

```bash
with torch.no_grad():
    model_output = model(**encoded_input)

# Perform pooling
sentence_embeddings = mean_pooling(model_output, encoded_input['attention_mask'])

# Normalize embeddings
sentence_embeddings = F.normalize(sentence_embeddings, p=2, dim=1)

print("Sentence embeddings:")
print(sentence_embeddings)
```

Finally over embeddings are ready now we will find the **Cosine Score** for above two sentences

```bash
cos =  torch.nn.CosineSimilarity(dim=0, eps=1e-6)
output = cos(sentence_embeddings[0], sentence_embeddings[1])
print(output)
```

As a last step in output we get the sentence similarity scrore based on the model predict.

## Conclusion

As demonstrated, setting up an LLM model locally on your Macbook can be a straightforward process that allows you to leverage the power of machine learning for natural language processing tasks. We can use vast array of resources and models available through Hugging Face and other libraries, you can enhance your natural language processing and machine learning workflows and take your projects to the next level.

That's it for today 🙌

## Resources

- [Hugging face Model](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2)
- [Reasearch Paper](https://arxiv.org/abs/2002.10957)

```

```
