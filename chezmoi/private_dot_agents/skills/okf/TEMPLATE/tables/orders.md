---
type: BigQuery Table
title: Orders
description: One row per completed customer order across all channels.
resource: https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders
tags: [sales, orders, revenue]
timestamp: 2026-05-28T14:30:00Z
---

## Schema

| Column        | Type    | Description                              |
|---------------|---------|------------------------------------------|
| `order_id`    | STRING  | Globally unique order identifier.        |
| `customer_id` | STRING  | FK to [customers](/tables/customers.md). |
| `total_usd`   | NUMERIC | Order total in US dollars.               |

## Citations

[1] [BigQuery table schema](https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders)
