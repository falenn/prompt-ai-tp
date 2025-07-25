# prompt-ai-tp
AI LLM Data Drift-Detection Pipeline
From [Grok 3](https://grok.com/chat/1c64ae98-b632-49ac-82bf-53411c2d675c)


## Prompt Guidence
Design a [goal] using [technologies/services] for [use case]. Provide:
1. A concise architecture overview (key components, data flow).
2. Terraform code for infrastructure (AWS resources, minimal configuration).
3. Python code for [specific tasks, e.g., PySpark processing, ML model].
Constraints: [e.g., cost-efficient, batch processing, region us-east-1].
Base the design on [context, e.g., provided JSON schema with schema_version].
Keep code minimal and functional; explain only critical design choices.

### Why This Works
Clarity: Specifies the goal, deliverables, and constraints upfront.
Focus: Requests minimal, functional code and targeted explanations, reducing verbosity.
Contextual: References prior examples (e.g., JSON schema) to ensure relevance.
Structured: Uses numbered deliverables to organize the response, making it easier for the LLM to follow.

### Tips for RFP-Style Prompts
Use “Shall” Consistently: Reserve “shall” for mandatory requirements; use “should” for preferences (e.g., “The system should prioritize cost over latency”).
Number Requirements: List deliverables and constraints numerically (e.g., 1.1, 1.2) for traceability.
Be Specific: Quantify constraints (e.g., “$50/month” vs. “cost-efficient”) to avoid ambiguity.
Include Verification: Add how requirements will be validated (e.g., “The pipeline shall process 10 GB/day, verified by CloudWatch metrics”).
Keep Concise: Avoid excessive “shall” statements by grouping related requirements (e.g., combine S3 buckets into one statement).

```
goal: AWS data pipeline for IoT schema drift detection
context: The system shall use the provided JSON schema (schema_version: "1.0.0"). Explain only critical design choices.
requirements:
  - The system shall process 10 GB/day within $50/month.
  - The system shall use us-east-1.
  - The system shall perform batch processing every 5-15 minutes.
deliverables: [...]
```

### User Story Style
User Stories
Format: Typically written as "As a [role], I want [functionality] so that [benefit]." This focuses on user needs, intent, and outcomes.
Advantages:
User-Centric: Emphasizes the stakeholder’s perspective (e.g., data engineer, IoT system admin), making it intuitive for defining functional goals.
Outcome-Focused: Highlights the "why" (benefit), which helps the LLM prioritize design choices (e.g., cost efficiency for budget-conscious users).
Concise: Captures requirements in a compact, narrative format, reducing verbosity.
Iterative: Encourages refinement, aligning with agile development principles.
Disadvantages:
Limited Specificity: May lack detailed technical constraints (e.g., AWS region, exact budget), requiring additional clarification.
Nuance Dependency: The "so that" clause may not fully capture complex technical requirements or trade-offs.
Less Formal: May feel too informal for rigid, contract-like specifications.

```
As a data engineer, I want an AWS data pipeline to detect schema drift in IoT sensor data (JSON with schema_version, device_id, timestamp, location, readings, status) from S3 to Data Firehose, using Parquet and SparkSQL, so that I can ensure data quality cost-efficiently. 

Deliverables:
1. Architecture overview describing components (S3, Firehose, Glue) and data flow.
2. Terraform code to provision S3 buckets, Data Firehose, Glue job, and IAM roles in us-east-1.
3. Python code for PySpark to convert JSON to Parquet, validate schema, and detect drift using IsolationForest.

Acceptance Criteria:
- Pipeline processes 10 GB/day within $50/month.
- Batch processing occurs every 5-15 minutes.
- Uses provided JSON schema (schema_version: "1.0.0").
- Code is minimal, functional, with critical design choices explained.
```

