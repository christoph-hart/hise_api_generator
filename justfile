# Local distribution targets. Override paths with HISE_WEBSITE_ROOT and HISE_MCP_ROOT.
set dotenv-load := false

website_root := env_var_or_default("HISE_WEBSITE_ROOT", "../../../Development/hise_website_v2")
mcp_root := env_var_or_default("HISE_MCP_ROOT", "../../../Development/hise_mcp_server")
mcp_data := mcp_root + "/data"

# Regenerate and distribute all API and documentation data to local targets.
publish:
	python3 api_enrich.py merge
	python3 api_enrich.py filter-mcp --output "{{mcp_data}}/scripting_api.json"
	cp enrichment/output/api_reference.json "{{mcp_data}}/api_reference.json"
	python3 api_enrich.py preview
	python3 publish.py "{{website_root}}/content/v2" --strict
	cd "{{mcp_root}}" && just rebuild-embeddings
