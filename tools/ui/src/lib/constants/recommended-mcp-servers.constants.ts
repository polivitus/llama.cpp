import type { RecommendedMCPServer } from '$lib/types';

// Suggested MCP servers shown as opt-in cards in the "Add New Server" dialog.
// Rendering these cards never reaches the upstream domain - favicons come
// from local bundles in static/recommended-mcp/ and the URL is only used
// after the user clicks Add.
export const RECOMMENDED_MCP_SERVERS: RecommendedMCPServer[] = [
	{
		description: 'Поиск в интернете и получение содержимого страниц в виде чистого Markdown.',
		iconUrl: '/recommended-mcp/exa.ico',
		id: 'exa',
		name: 'Exa',
		url: 'https://mcp.exa.ai/mcp'
	},
	{
		description: 'Поиск и просмотр AI-моделей, датасетов, пространств и документации на Hugging Face Hub.',
		iconUrl: '/recommended-mcp/huggingface.ico',
		id: 'huggingface',
		name: 'Hugging Face',
		url: 'https://huggingface.co/mcp'
	},
	{
		description: 'Поиск репозиториев, задач, запросов на слияние и взаимодействие с кодом на GitHub.',
		iconUrlDark: '/recommended-mcp/github-dark.png',
		iconUrlLight: '/recommended-mcp/github-light.png',
		id: 'github',
		name: 'GitHub',
		needsAuthorization: true,
		url: 'https://api.githubcopilot.com/mcp'
	},
	{
		description: 'Просмотр актуальной документации и примеров кода для библиотек и фреймворков.',
		iconUrl: '/recommended-mcp/context7.png',
		id: 'context7',
		name: 'Context7',
		url: 'https://mcp.context7.com/mcp'
	}
];
