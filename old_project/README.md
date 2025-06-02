# ContractSmarts R2R 

## Introduction

## Table of Contents


- [Appendix: Azure Deployment](#appendix-deployment-of-azure-openai-models)

## Deployment Facts

### Azure Endpoint
`https://cs-open-ai-01.openai.azure.com/` 


# Background

# Query 1:
I am installing an R2R standalone platform based on their docker compose in an Azure framework. I have docker installed and the specific packages pulled.

Rather than using the defaults, I will be using the Azure OpenAI models within the azure ecosystem. I am not completely sure how to set that up. Can you help me? I can give you the Azure key.


## Response 1
Yes, I can walk you through how to configure the R2R standalone platform to use **Azure OpenAI** models instead of the default OpenAI API. You don’t need to share your key—I'll show you where to place it safely.

### ✅ High-Level Steps:

1. **Locate the R2R configuration file.**
2. **Set environment variables for Azure OpenAI.**
3. **Update the R2R model configuration to use Azure endpoints.**
4. **Restart your Docker containers.**

---

### 🔧 Step-by-Step Configuration for Azure OpenAI in R2R

#### 1. **Find the model settings file**

R2R typically uses a config file like `r2r.yaml` or environment variables in `.env` or `docker-compose.yml`. You’ll want to override the following settings:

#### 2. **Set Azure OpenAI Variables**

Azure OpenAI uses a different API format than OpenAI's default. Here's how to set it:

##### Required variables:

```env
R2R_MODEL_PROVIDER=azure
AZURE_OPENAI_API_KEY=your-azure-openai-key
AZURE_OPENAI_ENDPOINT=https://<your-resource-name>.openai.azure.com/
AZURE_OPENAI_DEPLOYMENT_NAME=your-deployment-name
AZURE_OPENAI_API_VERSION=2023-05-15  # Or the latest supported
```

Add these to either:

* Your `.env` file
* Or as `environment:` variables inside `docker-compose.yml` for the `r2r-server` container.

---

#### 3. **Configure model usage**

R2R may let you specify model usage like this:

```yaml
llm:
  provider: azure
  deployment_name: your-deployment-name
  endpoint: https://<your-resource-name>.openai.azure.com/
  api_key: ${AZURE_OPENAI_API_KEY}
  api_version: 2023-05-15
```

Some setups might expect the model to be called `gpt-35-turbo` or similar; this depends on how you named your Azure deployment.

---

#### 4. **Restart the Docker service**

```bash
docker compose down
docker compose up -d
```

Make sure your containers pick up the new environment variables.

---

### ✅ Verifying the Setup

You can run a test query or curl command like:

```bash
curl https://<your-resource-name>.openai.azure.com/openai/deployments/<your-deployment-name>/chat/completions?api-version=2023-05-15 \
  -H "api-key: $AZURE_OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{"role":"user","content":"Hello!"}],
    "max_tokens": 50
  }'
```

---

Would you like me to look at your `docker-compose.yml` or `.env` to tailor the instructions further?




# Query 3: 
What would you suggest as a good model for a RAG application? I need at very least both a text embedding model (text-embedding-3-large or text-embedding-3-small?) and a gpt-4o or gpt-4o-mini for chat? Or should I use multiples depending on the situation?

## Response 3: RAG Application Model Recommendations
Great question—when building a **Retrieval-Augmented Generation (RAG)** app on Azure, the model choices significantly impact **latency**, **cost**, and **quality**. Below is a practical, opinionated guide based on current Azure offerings as of mid-2025:

---

## 🔍 1. **Embedding Model**

### ✅ Recommended: `text-embedding-3-small`

* **Use case**: Document chunk embedding and semantic search.
* **Why**:

  * Nearly identical embedding quality to `3-large` for RAG use cases.
  * Faster and significantly cheaper.
  * Lower memory overhead—great if you’re embedding large corpora.

### 📌 When to use `text-embedding-3-large`:

* You need higher **dimensionality (3072 vs 1536)** for nuanced similarity clustering.
* You’re doing more than RAG (e.g., custom semantic search at scale, clustering, or scientific applications).

---

## 💬 2. **Chat Model**

### ✅ Recommended: `gpt-4o`

* **Use case**: Final answer generation in your RAG pipeline.
* **Why**:

  * Much faster and cheaper than GPT-4 Turbo, with similar or better quality.
  * Especially good for long-context and tool-augmented generation.
  * Supports **128k** context windows—excellent for long documents.

### 📉 Alternative: `gpt-4o-mini` or `gpt-35-turbo` for:

* **Fast summaries**, fuzzy searching, or pre-filtering content before calling `gpt-4o`.
* Low-cost or real-time constraints where perfect fluency isn’t essential.

---

## 🧠 Suggested Setup for Most Use Cases

```yaml
embedding_model:
  name: text-embedding-3-small
  deployment_name: embedding-3-small

chat_model:
  name: gpt-4o
  deployment_name: chat-gpt4o
```

Optionally:

* Add a `gpt-4o-mini` or `gpt-35-turbo` deployment for cost-sensitive tasks.

---

## 🧪 Bonus: Use Multiple Chat Models Strategically

* Use `gpt-35-turbo` or `4o-mini` to **generate summaries** or quick metadata.
* Use `gpt-4o` only when composing the final user-facing answer.
* **Fallback behavior**: If latency or quota fails, you can switch to a cheaper/faster model programmatically.

---

Would you like a YAML or `.env` layout showing how to specify both embedding and chat models with Azure in R2R?

# Query 4:

Please show me both a yaml file and a .env file layout for including text-embedding-3-small, gpt-4o, and 4o-mini for summaries (which we do a lot of).

## Response 4: RAG Model choices

Absolutely — here's a clean setup using **three Azure OpenAI deployments**:

* `text-embedding-3-small` for embeddings
* `gpt-4o` for chat/answers
* `gpt-4o-mini` for fast summaries

I'll show both the `.env` and `r2r.yaml` formats below 👇

---

## ✅ `.env` File Layout

You can reference these values from your `docker-compose.yml` or the `r2r.yaml`.

```dotenv
# == Embedding Model ==
AZURE_EMBEDDING_DEPLOYMENT=text-embedding-3-small
AZURE_EMBEDDING_ENDPOINT=https://cs-open-ai-01.openai.azure.com/
AZURE_EMBEDDING_API_KEY=your-key-here
AZURE_EMBEDDING_API_VERSION=2024-02-15-preview

# == Main Chat Model (Answer Generation) ==
AZURE_CHAT_DEPLOYMENT=gpt-4o
AZURE_CHAT_ENDPOINT=https://cs-open-ai-01.openai.azure.com/
AZURE_CHAT_API_KEY=your-key-here
AZURE_CHAT_API_VERSION=2024-02-15-preview

# == Fast Summarization Model ==
AZURE_SUMMARY_DEPLOYMENT=gpt-4o-mini
AZURE_SUMMARY_ENDPOINT=https://cs-open-ai-01.openai.azure.com/
AZURE_SUMMARY_API_KEY=your-key-here
AZURE_SUMMARY_API_VERSION=2024-02-15-preview
```

---

## ✅ `r2r.yaml` (or equivalent config file)

```yaml
llm:
  provider: azure
  models:
    embedding:
      deployment_name: ${AZURE_EMBEDDING_DEPLOYMENT}
      endpoint: ${AZURE_EMBEDDING_ENDPOINT}
      api_key: ${AZURE_EMBEDDING_API_KEY}
      api_version: ${AZURE_EMBEDDING_API_VERSION}
      model: text-embedding-3-small

    chat:
      deployment_name: ${AZURE_CHAT_DEPLOYMENT}
      endpoint: ${AZURE_CHAT_ENDPOINT}
      api_key: ${AZURE_CHAT_API_KEY}
      api_version: ${AZURE_CHAT_API_VERSION}
      model: gpt-4o

    summarization:
      deployment_name: ${AZURE_SUMMARY_DEPLOYMENT}
      endpoint: ${AZURE_SUMMARY_ENDPOINT}
      api_key: ${AZURE_SUMMARY_API_KEY}
      api_version: ${AZURE_SUMMARY_API_VERSION}
      model: gpt-4o-mini
```

---

### 🧩 Notes:

* R2R may require that you customize how it *uses* the `summarization` model depending on whether it supports multiple chat roles. If not natively supported, you can use this in **custom Python code or pipeline plugins** to explicitly call that model for summaries.
* Make sure each model is actually deployed under the names used in `deployment_name`.

---

Would you like me to generate a `docker-compose.override.yml` to inject these `.env` variables if needed?

# Creating a docker-compose.override.yml file

Here’s a `docker-compose.override.yml` file that will inject the environment variables for Azure OpenAI models into your **R2R server container** (usually named `r2r-server` in the base Docker Compose file):

---

### ✅ `docker-compose.override.yml`

```yaml
version: "3.8"

services:
  r2r-server:
    environment:
      # Embedding Model
      AZURE_EMBEDDING_DEPLOYMENT: text-embedding-3-small
      AZURE_EMBEDDING_ENDPOINT: https://cs-open-ai-01.openai.azure.com/
      AZURE_EMBEDDING_API_KEY: ${AZURE_EMBEDDING_API_KEY}
      AZURE_EMBEDDING_API_VERSION: 2024-02-15-preview

      # Chat Model (for answers)
      AZURE_CHAT_DEPLOYMENT: gpt-4o
      AZURE_CHAT_ENDPOINT: https://cs-open-ai-01.openai.azure.com/
      AZURE_CHAT_API_KEY: ${AZURE_CHAT_API_KEY}
      AZURE_CHAT_API_VERSION: 2024-02-15-preview

      # Summary Model (for fast summarization)
      AZURE_SUMMARY_DEPLOYMENT: gpt-4o-mini
      AZURE_SUMMARY_ENDPOINT: https://cs-open-ai-01.openai.azure.com/
      AZURE_SUMMARY_API_KEY: ${AZURE_SUMMARY_API_KEY}
      AZURE_SUMMARY_API_VERSION: 2024-02-15-preview
```

---

### 📌 How to Use

1. Save this file as `docker-compose.override.yml` in the same directory as your `docker-compose.yml`.

2. Ensure your `.env` file includes:

   ```dotenv
   AZURE_EMBEDDING_API_KEY=...
   AZURE_CHAT_API_KEY=...
   AZURE_SUMMARY_API_KEY=...
   ```

3. Then start or restart your R2R stack:

   ```bash
   docker compose down
   docker compose up -d
   ```

Docker will automatically merge this `override` file into your base Compose configuration.

---

Would you like to include volume mounts or a custom config path in this override file as well?

# Query: Update current r2r-azure.toml
This is my current r2r-azure.toml file

```toml
[app]
# LLM used for internal operations, like deriving conversation names
fast_llm = "azure/gpt-4o-mini"

# LLM used for user-facing output, like RAG replies
quality_llm = "azure/gpt-4o"

# LLM used for ingesting visual inputs
vlm = "azure/gpt-4o"

# LLM used for transcription
audio_lm = "azure/whisper-1"

# Reasoning model, used for `research` agent
reasoning_llm = "azure/o3-mini"

# Planning model, used for `research` agent
planning_llm = "azure/o3-mini"

[embedding]
base_model = "azure/text-embedding-3-small"
# leave blank for default base_dimension
#base_dimension = 512

[completion_embedding]
base_model = "azure/text-embedding-3-small"

[ingestion]
provider = "unstructured_local"
strategy = "auto"
chunking_strategy = "by_title"
new_after_n_chars = 2_048
max_characters = 4_096
combine_under_n_chars = 1_024
overlap = 1_024
document_summary_model = "azure/gpt-4o-mini"
automatic_extraction = true # enable automatic extraction of entities and relations

  [ingestion.extra_parsers]
    pdf = ["zerox", "ocr"]

  [ingestion.chunk_enrichment_settings]
    generation_config = { model = "azure/gpt-4o-mini" }

[orchestration]
provider = "hatchet"
kg_creation_concurrency_limit = 32
ingestion_concurrency_limit = 4
kg_concurrency_limit = 8

## Database Limits (not required but adjustable)
## these values are unreasonably small but made this way to be testable

#[database]
#  [database.limits]
#  global_per_min = 10  # Small enough to test quickly
#  monthly_limit = 20  # Small enough to test in one run
#
#  [database.route_limits]
#  "/v3/retrieval/search" = { route_per_min = 5, monthly_limit = 10 }
#
#  [database.user_limits."47e53676-b478-5b3f-a409-234ca2164de5"]
#  global_per_min = 2
#  route_per_min = 1

## Optional auth section
##

#[auth]
#provider = "r2r"
#access_token_lifetime_in_minutes = 60
#refresh_token_lifetime_in_days = 7
#require_authentication = true
#require_email_verification = false
#default_admin_email = "admin@example.com"
#default_admin_password = "change_me_immediately"
```

along with some optional settings that I have not set yet. The file is based on R2R's config for Azure.

In the R2R setting, how do the env variables and the toml variables interact? I don't want contradictory settings. Also, it seems from above that a lot more information is needed to configure each of the models: gpt-4o-mini, gpt-4o, text-embedding-3-small, etc. Can you help me with an appropriate .env file and an appropriate toml file?


## Response: Full R2R toml file
Thanks for sharing your full `r2r-azure.toml` file — it gives excellent context. Here's a clear breakdown of how **R2R handles environment variables vs TOML config**, and then I’ll walk you through how to make **both files consistent and complete** for Azure OpenAI usage.

---

## ⚙️ How Environment Variables and the `.toml` File Interact in R2R

R2R handles configuration in **layers**:

1. **`.toml` config** (like `r2r-azure.toml`) is the main configuration file.
2. **Environment variables** override values **only where explicitly supported** — often for **API keys**, **endpoints**, or values in `.env`-driven containers.

In your case:

* The TOML file declares the model names (e.g., `"azure/gpt-4o"`), but **the actual Azure deployment names, keys, and endpoints must come from environment variables**.
* The string `"azure/gpt-4o"` in the TOML tells R2R to look up:

  * What deployment to call,
  * Which endpoint,
  * What API version,
  * And the key — **all from environment variables**.

---

## ✅ Clean and Complete `.env` File

Here’s a clean, **deduplicated** `.env` file to match your TOML:

```dotenv
# === Azure OpenAI Common Endpoint and API Version ===
AZURE_OPENAI_ENDPOINT=https://cs-open-ai-01.openai.azure.com/
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# === Azure API Key ===
AZURE_OPENAI_API_KEY=your-key-here

# === Deployment Names (these must match names in Azure portal) ===
# Main models
AZURE_DEPLOYMENT_GPT_4O=gpt-4o
AZURE_DEPLOYMENT_GPT_4O_MINI=gpt-4o-mini
AZURE_DEPLOYMENT_WHISPER_1=whisper-1

# Reasoning and planning (if o3-mini is deployed under a different name)
AZURE_DEPLOYMENT_O3_MINI=o3-mini

# Embedding model
AZURE_DEPLOYMENT_EMBEDDING=text-embedding-3-small
```

---

## ✅ Matching `r2r-azure.toml` (Final Version)

Update your TOML slightly so it's clean and references only valid keys:

```toml
[app]
# Internal fast tasks (e.g., name generation)
fast_llm = "azure/gpt-4o-mini"

# Main chat model for user-facing RAG output
quality_llm = "azure/gpt-4o"

# For visual input (image/video): same as main model
vlm = "azure/gpt-4o"

# Audio transcription model
audio_lm = "azure/whisper-1"

# Research agent models
reasoning_llm = "azure/o3-mini"
planning_llm  = "azure/o3-mini"

[embedding]
base_model = "azure/text-embedding-3-small"
# Optional: base_dimension = 1536

[completion_embedding]
base_model = "azure/text-embedding-3-small"

[ingestion]
provider = "unstructured_local"
strategy = "auto"
chunking_strategy = "by_title"
new_after_n_chars = 2048
max_characters = 4096
combine_under_n_chars = 1024
overlap = 1024
document_summary_model = "azure/gpt-4o-mini"
automatic_extraction = true

  [ingestion.extra_parsers]
  pdf = ["zerox", "ocr"]

  [ingestion.chunk_enrichment_settings]
  generation_config = { model = "azure/gpt-4o-mini" }

[orchestration]
provider = "hatchet"
kg_creation_concurrency_limit = 32
ingestion_concurrency_limit = 4
kg_concurrency_limit = 8
```

---

## 🧠 How R2R Resolves `"azure/gpt-4o"` Internally

When R2R sees a model string like `"azure/gpt-4o"` it looks for:

```bash
AZURE_DEPLOYMENT_GPT_4O
AZURE_OPENAI_API_KEY
AZURE_OPENAI_ENDPOINT
AZURE_OPENAI_API_VERSION
```

And then uses those to call the correct deployment with the correct model.

> ✅ So as long as your `.env` has **correct deployment mappings**, you’re good — no conflict between TOML and environment variables.

---

### ✅ Optional: Sanity Check with Azure Portal

Make sure you have the following deployments in your Azure OpenAI resource:

* `gpt-4o` (for chat)
* `gpt-4o-mini` (for summaries)
* `text-embedding-3-small` (for embedding)
* `whisper-1` (for audio)
* `o3-mini` (if using for planning/reasoning)

---

Would you like a script to validate that your `.env` values match real deployments via the Azure API?

# Query:

Based on your prior advice, I think I will replace the o3-mini with o4-mini. Am I correct in remembering that will improve both planning and reasoning?


# Query:
Please give me a summary of recommended deployment names to copy into Azure


# Response: Deployment names

Here’s a clear, ready-to-copy summary of **recommended deployment names** for your Azure OpenAI resource to support your R2R use case:

---

### 📝 Deployment Instructions (Summary)

For each model:

1. Go to your Azure OpenAI resource:
   [https://portal.azure.com](https://portal.azure.com)

2. Click **Deployments** → **+ Create**

3. Fill out:

   * **Model**: Choose from dropdown (e.g., `gpt-4o`)
   * **Model version**: Choose latest (e.g., `2024-02-15-preview`)
   * **Deployment name**: Paste in the `Deployment Name` above (e.g., `gpt-4o`)
   * **SKU/Quota**: Leave default unless limited
   * Click **Create**

Repeat for each model listed.

---

Would you like a printable table or CSV format version of this for documentation?

# Query

Can you explain other settings for me? What is hatchet used for? Should I specify settings or use the defaults throughout?


# Response: Hatchet and Auth

Absolutely — let’s walk through the **other settings** in your `r2r-azure.toml`, especially focusing on `hatchet`, and whether you should customize anything beyond the defaults.

---


---

## 🔍 Other Sections You Might Want to Customize

### 🔸 `[ingestion]`

You're already using a smart setup:

```toml
chunking_strategy = "by_title"
new_after_n_chars = 2048
combine_under_n_chars = 1024
```

These help keep chunks semantically meaningful. You may want to:

* Increase `max_characters = 8192` if you have long legal docs
* Set `document_summary_model = "azure/gpt-4o-mini"` for fast summarization (you already did)

---

### 🔸 `[embedding]` and `[completion_embedding]`

You can leave these as-is unless you want to override dimensions:

```toml
base_dimension = 1536  # optional: set explicitly for clarity
```

---

### 🔸 `[database]` and `[auth]`

These are optional.

* Use `[database.limits]` if you're building a **multi-tenant platform** and want to enforce rate or quota limits.
* Use `[auth]` if you're enforcing **logins, access control**, or want to seed a default admin.

You can leave these out for now unless your deployment is shared.

---

## ✅ Summary: Should You Use Defaults?

| Component     | Use Default? | When to Customize                     |
| ------------- | ------------ | ------------------------------------- |
| `hatchet`     | ✅ Yes        | Only tweak concurrency if needed      |
| `[ingestion]` | ✅ Mostly     | Tweak chunk sizes & overlap as needed |
| `[embedding]` | ✅ Yes        | Optional: set dimension explicitly    |
| `[auth]`      | ❌ Optional   | Add if enforcing user auth            |
| `[database]`  | ❌ Optional   | Add for quotas/rate limits            |

---

Would you like me to provide a version of your `r2r-azure.toml` that includes only the most useful and tuned overrides, and cleanly comments out the optional stuff for future use?

# Query
Provide a version of r2r-azure.toml as described. We may add database and auth later, although we may use a different auth protocol from what is provided by default by R2R. Have those entries available but commented out, with commented explanations where necessary of good settings we might want to consider (if not the default)

# Response

Here's a clean, production-ready version of your `r2r-azure.toml`, structured for clarity, performance, and future extensibility.

* ✅ **Default-safe where appropriate**
* 🛠️ **Tuned where beneficial**
* 💬 **Commented out `auth` and `database` sections** for easy future activation

---

### ✅ `r2r-azure.toml`

```toml
[app]
# LLM used for internal operations (e.g., naming, summaries)
fast_llm = "azure/gpt-4o-mini"

# LLM used for RAG answers and end-user-facing chat
quality_llm = "azure/gpt-4o"

# LLM used for processing visual inputs (same as main model unless split)
vlm = "azure/gpt-4o"

# Model used for audio transcription (Whisper)
audio_lm = "azure/whisper-1"

# Models used by the research agent (e.g., multi-step reasoning)
reasoning_llm = "azure/o4-mini"
planning_llm  = "azure/o4-mini"


[embedding]
# Used for document vectorization
base_model = "azure/text-embedding-3-small"
# Optional: explicitly set embedding dimensionality (1536 for text-embedding-3-small)
# base_dimension = 1536


[completion_embedding]
# Used for embedding LLM completions (e.g., enriched summaries)
base_model = "azure/text-embedding-3-small"


[ingestion]
provider = "unstructured_local"
strategy = "auto"                         # auto-select best parser per file type
chunking_strategy = "by_title"           # keep chunks aligned with sections
new_after_n_chars = 2048                 # split chunks when title is far away
max_characters = 4096                    # upper limit for any single chunk
combine_under_n_chars = 1024            # small chunks get merged
overlap = 1024                           # soft overlap between adjacent chunks

document_summary_model = "azure/gpt-4o-mini"
automatic_extraction = true             # enable extraction of entities and relations

  [ingestion.extra_parsers]
  pdf = ["zerox", "ocr"]                # use ZeroX (PDF layer) and OCR as fallbacks

  [ingestion.chunk_enrichment_settings]
  generation_config = { model = "azure/gpt-4o-mini" }


[orchestration]
provider = "hatchet"                    # built-in orchestrator
kg_creation_concurrency_limit = 16     # reasonable parallelism for medium VMs
ingestion_concurrency_limit = 4        # align with vCPU count
kg_concurrency_limit = 4               # tune if knowledge graph step is intensive


# ------------------------------------------------------
# [database] section: Enable for rate limiting & quotas
# ------------------------------------------------------
#[database]
#  [database.limits]
#  # Per-R2R global rate limits
#  global_per_min = 60           # number of requests per minute allowed
#  monthly_limit = 10000         # total requests allowed per month
#
#  [database.route_limits]
#  "/v3/retrieval/search" = { route_per_min = 30, monthly_limit = 5000 }
#
#  # Optional: User-specific rate limiting (by user UUID)
#  [database.user_limits."47e53676-b478-5b3f-a409-234ca2164de5"]
#  global_per_min = 10
#  route_per_min = 5


# ------------------------------------------------------
# [auth] section: Optional; enable for login, access control
# ------------------------------------------------------
#[auth]
#provider = "r2r"                        # Options: r2r, oidc (experimental)
#access_token_lifetime_in_minutes = 60
#refresh_token_lifetime_in_days = 7
#require_authentication = true          # Enforce login for all endpoints
#require_email_verification = false     # Turn on if you're sending emails
#default_admin_email = "admin@example.com"
#default_admin_password = "change_me_immediately"
#
## For OIDC (e.g., Auth0, Azure AD) — future option
#[auth.oidc]
#issuer_url = "https://login.microsoftonline.com/your-tenant-id/v2.0"
#client_id = "your-client-id"
#client_secret = "your-client-secret"
#redirect_uri = "https://your-app-url/callback"
```

---

### 🔍 Key Notes

* This config **requires no changes to R2R internals** and is **fully environment-variable compatible**.
* You can safely leave this in version control with `.env` values excluded.
* The `[auth]` and `[database]` sections are **ready to be uncommented** when you're ready to layer in multi-user control or rate limiting.

---

Would you like a companion `.env.template` file to document what values your team needs to set?

# Query
Provide a .env.template file for me as well.


# Response: env.template file
Here's a well-documented `.env.template` file to accompany your `r2r-azure.toml`. It includes all required and optional values, grouped by purpose and annotated so your team knows what each variable controls.

---

### ✅ `.env.template`

```dotenv
# =========================================
# 🔐 Azure OpenAI API Credentials
# =========================================

# The endpoint for your Azure OpenAI resource (do not include trailing slash)
AZURE_OPENAI_ENDPOINT=https://cs-open-ai-01.openai.azure.com

# API version for your deployed models (2024-02-15-preview or newer)
AZURE_OPENAI_API_VERSION=2024-02-15-preview

# The API key associated with your Azure OpenAI resource
AZURE_OPENAI_API_KEY=your-azure-openai-key-here


# =========================================
# 🧠 Model Deployment Names (must match Azure)
# =========================================

# === Main RAG Answer Model ===
AZURE_DEPLOYMENT_GPT_4O=gpt-4o

# === Fast summary / internal tasks model ===
AZURE_DEPLOYMENT_GPT_4O_MINI=gpt-4o-mini

# === Reasoning & Planning model (used by agents) ===
AZURE_DEPLOYMENT_O4_MINI=o4-mini

# === Embedding model for document vectorization ===
AZURE_DEPLOYMENT_EMBEDDING=text-embedding-3-small

# === Transcription (if using audio input) ===
AZURE_DEPLOYMENT_WHISPER_1=whisper-1


# =========================================
# 🧪 Optional: Auth Settings (if [auth] is enabled)
# =========================================

# R2R_DEFAULT_ADMIN_EMAIL=admin@example.com
# R2R_DEFAULT_ADMIN_PASSWORD=change_me_immediately

# OIDC-specific variables (if using external SSO like Azure AD or Auth0)
# OIDC_ISSUER_URL=https://login.microsoftonline.com/<tenant-id>/v2.0
# OIDC_CLIENT_ID=your-client-id
# OIDC_CLIENT_SECRET=your-client-secret
# OIDC_REDIRECT_URI=https://your-app-url/callback


# =========================================
# 🧱 Optional: Database Limits (if [database] is enabled)
# =========================================

# R2R_GLOBAL_REQUEST_LIMIT_PER_MINUTE=60
# R2R_GLOBAL_MONTHLY_REQUEST_LIMIT=10000
# R2R_SEARCH_ROUTE_LIMIT_PER_MIN=30
# R2R_SEARCH_MONTHLY_LIMIT=5000
```

---

### 📌 Usage

* Rename this file to `.env` in your deployment environment.
* Keep this version (`.env.template`) in version control so collaborators know what to fill in.

---

Would you like a pre-built `docker-compose.override.yml` that loads all of these automatically with this structure?

# Appendices 

## Appendix: Deployment of Azure OpenAI models

You **must create a deployment** of a specific model (e.g., GPT-4, GPT-3.5-turbo) in Azure OpenAI *before* you can use it with R2R or any other app. Here’s how to do that:

---

### 🧭 Step-by-Step: Create a Deployment in Azure OpenAI

#### ✅ Prerequisites:

* You have access to an Azure subscription and the **Azure OpenAI** resource `cs-open-ai-01`.
* You’ve been granted access to use models in that region (via Microsoft’s approval process).

---

### 🔧 Steps in Azure Portal:

#### 1. **Go to Azure Portal**

Visit: [https://portal.azure.com](https://portal.azure.com)

---

#### 2. **Navigate to your Azure OpenAI Resource**

* Search for **"Azure OpenAI"** in the top search bar.
* Select your resource: `cs-open-ai-01`.

---

#### 3. **Click on "Deployments" in the sidebar**

---

#### 4. **Click "Create"**

Now you'll set the details for the model deployment.

* **Model**: Choose from available models (e.g., `gpt-35-turbo`, `gpt-4`)
* **Model version**: Use the latest (e.g., `0613`, `1106`, `2024-02-15-preview`, etc.)
* **Deployment name**: Set something simple like:

  * `gpt-35`
  * `chat-gpt-4`
  * `cs-gpt` (whatever makes sense to you)
* **SKU** (optional): Keep default unless you need specific scale.
* **Capacity**: Leave as default unless provisioning capacity is required for your subscription.

Click **"Create"**.

---

#### 5. **Note your values**

Once deployed, you’ll need:

* `AZURE_OPENAI_DEPLOYMENT_NAME`: the name you gave your deployment
* `AZURE_OPENAI_ENDPOINT`: still `https://cs-open-ai-01.openai.azure.com/`
* `AZURE_OPENAI_API_VERSION`: usually something like `2023-05-15` or `2024-02-15-preview` depending on model/version

You’ll then plug these into your `.env` or `docker-compose.yml`.

---

### 🧪 Optional: Test It

Azure provides a **Playground** under your resource to test prompts right from the portal before wiring up your app.

## Appendix: Compare o3-mini with o4-mini

Replacing `o3-mini` with `o4-mini` for both **reasoning** and **planning** in your R2R setup is a **solid upgrade** for the following reasons:

---

### ✅ Why `o4-mini` Is Better than `o3-mini` for Planning & Reasoning

| Feature                | `o3-mini`                  | `o4-mini`                    |
| ---------------------- | -------------------------- | ---------------------------- |
| **Architecture**       | GPT-3.5-like               | GPT-4o-family                |
| **Reasoning Quality**  | Moderate                   | Significantly improved       |
| **Speed**              | Fast                       | Fast                         |
| **Cost**               | Similar or slightly higher | Efficient per token          |
| **Context Window**     | \~16k                      | 128k                         |
| **Multimodal Support** | No                         | Yes (optional, not required) |

* `o4-mini` benefits from **GPT-4o optimizations** even in its lighter form.
* Better **task planning**, **code generation**, and **multi-step reasoning**.
* Still fast and economical compared to full `gpt-4o`.

---

### 🔄 Update for Your `r2r-azure.toml`

```toml
[app]
reasoning_llm = "azure/o4-mini"
planning_llm  = "azure/o4-mini"
```

And in your `.env`:

```dotenv
AZURE_DEPLOYMENT_O4_MINI=o4-mini
```

Make sure the `o4-mini` deployment exists in Azure OpenAI under that name.

---

Let me know if you'd like a summary of recommended deployment names to copy into Azure.

## Appendix: ✅ Recommended Azure OpenAI Deployment Names

| **Purpose**                   | **Model Name (in Azure)** | **Deployment Name**      | **Notes**                                             |
| ----------------------------- | ------------------------- | ------------------------ | ----------------------------------------------------- |
| 🔍 **Embedding**              | `text-embedding-3-small`  | `text-embedding-3-small` | Fast, cost-effective for semantic search              |
| 🧠 **Main Chat (RAG output)** | `gpt-4o`                  | `gpt-4o`                 | High-quality reasoning and generation                 |
| ⚡ **Fast Summaries & UI**     | `gpt-4o-mini`             | `gpt-4o-mini`            | Cheaper, faster; great for summaries                  |
| 🎯 **Planning & Reasoning**   | `gpt-4o-mini`             | `o4-mini`                | Lighter GPT-4o used for internal agents               |
| 🖼️ **Multimodal / VLM**      | `gpt-4o` (vision capable) | `gpt-4o`                 | Same as main chat; reuse deployment if not separating |
| 🎙️ **Transcription**         | `whisper-1`               | `whisper-1`              | Only needed if you're ingesting audio                 |

### Follow up:
> Ask here why `o4-mini` name instead of `gpt-4o-mini`. I don't think they are the same. **Confirm.**


---
## Appendix: Hatchet

### 🧩 What is `hatchet`?

In the R2R platform, `hatchet` is the **default orchestration backend** that handles:

* **Task execution** (e.g., indexing, enrichment, retrieval)
* **Parallelism / concurrency**
* **Dependency tracking** during ingestion and knowledge graph creation
* Some light **workflow management**

Think of it as a built-in mini task orchestrator — *not* as full-featured as Airflow or Dagster, but well-tuned for R2R’s needs.

---

### 🔧 Section: `[orchestration]`

```toml
[orchestration]
provider = "hatchet"
kg_creation_concurrency_limit = 32
ingestion_concurrency_limit = 4
kg_concurrency_limit = 8
```

#### ✔️ When to change these:

| Setting                         | What it controls                            | Change it if...                                |
| ------------------------------- | ------------------------------------------- | ---------------------------------------------- |
| `provider = "hatchet"`          | Use the built-in orchestration system       | ✅ Leave as-is unless you're customizing deeply |
| `kg_creation_concurrency_limit` | Max # of documents concurrently added to KG | You're doing *very large* batch ingestions     |
| `ingestion_concurrency_limit`   | Max concurrent document parses & chunking   | You hit CPU/memory bottlenecks or want speed   |
| `kg_concurrency_limit`          | Max concurrent KG enrichment steps          | You hit performance or deadlock issues         |

#### ✅ Recommended Settings for Azure

```toml
[orchestration]
provider = "hatchet"
kg_creation_concurrency_limit = 16  # scale up if memory allows
ingestion_concurrency_limit = 4     # tune based on vCPU count
kg_concurrency_limit = 4
```

Start with **modest limits** and increase based on:

* Number of vCPUs on your Azure instance (e.g., F4s\_v2 = 4 vCPUs → keep concurrency ≤ 4–6)
* Memory capacity
* Disk I/O speed (if parsing large PDFs or OCR-heavy content)
