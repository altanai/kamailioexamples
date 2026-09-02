---
layout: default
title: Kamailio Examples
hide_title: true
description: A catalogue of Kamailio v5.x configurations for SIP routing, registration, NAT, WebRTC, RTPEngine media handling, load balancing, SBC, accounting, MOS and Lua scripting.
---

<div class="hero" markdown="0">
  <h1>Kamailio Examples</h1>
  <p>
    Working <code>kamailio.cfg</code> files and KEMI Lua scripts for the many roles a Kamailio
    server can take: registrar, proxy, load balancer, session border controller, WebRTC gateway
    and capture node. Every example is self contained and can be read on its own.
  </p>
  <div class="hero-actions">
    <a class="button" href="{{ '/Barebone_SIPServer/' | relative_url }}">Start with a barebone server</a>
    <a class="button secondary" href="{{ site.github_repo_url }}">Browse the repository</a>
  </div>
</div>

Examples target **Kamailio v5.x**. Older wiki-sourced configurations have been updated, but module
parameters still vary between minor releases, so check them against the
[module documentation](https://kamailio.org/docs/modules/) for the version you run.

{% for category in site.data.examples %}
<section class="category" id="{{ category.id }}" markdown="0">
  <h2>{{ category.name }}</h2>
  <p>{{ category.blurb }}</p>
  <div class="cards">
    {%- for item in category.items %}
    <a class="card" href="{{ item.path | prepend: '/' | relative_url }}">
      <strong>{{ item.title }}</strong>
      <span>{{ item.desc }}</span>
    </a>
    {%- endfor %}
  </div>
</section>
{% endfor %}

<section class="category" id="notes" markdown="0">
  <h2>Operational notes</h2>
  <p>Reference material that applies across the examples.</p>
  <div class="cards">
    {%- for ref in site.data.references %}
    <a class="card" href="{{ ref.path | prepend: '/' | relative_url }}">
      <strong>{{ ref.title }}</strong>
      <span>{{ ref.desc }}</span>
    </a>
    {%- endfor %}
  </div>
</section>

## Running an example

Each directory holds the configuration plus, where relevant, dispatcher lists, database seed files,
Lua modules and SIPp scenarios. To try one out:

```bash
git clone https://github.com/altanai/kamailioexamples.git
cd kamailioexamples/<example>

# sanity check the configuration before loading it
kamailio -c -f kamailio.cfg

# run it in the foreground with debug output
kamailio -f kamailio.cfg -DD -E
```

Adjust `listen`, `alias`, `mpath` and any database URLs to match your host before starting the
server. The [kamctl](kamctl_debug.md), [kamcmd](kamcmd_debug.md) and [sipsak](sipsak_debug.md)
notes cover inspecting a running instance.
