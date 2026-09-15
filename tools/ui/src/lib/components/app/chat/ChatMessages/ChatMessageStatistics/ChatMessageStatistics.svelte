<script lang="ts">
	import { BookOpenText, Clock, Gauge, Layers, Sparkles, WholeWord, Wrench } from '@lucide/svelte';
	import { ChatMessageStatisticsBadge } from '$lib/components/app';
	import * as Tooltip from '$lib/components/ui/tooltip';
	import { DEFAULT_PERFORMANCE_TIME, MS_PER_SECOND } from '$lib/constants';
	import { ChatMessageStatisticsMode, ChatMessageStatsView } from '$lib/enums';
	import type { ChatMessageAgenticTimings } from '$lib/types/chat';
	import { formatPerformanceTime } from '$lib/utils';
	import type { Component } from 'svelte';

	interface Props {
		predictedTokens?: number;
		predictedMs?: number;
		promptTokens?: number;
		promptMs?: number;
		isLive?: boolean;
		isProcessingPrompt?: boolean;
		initialView?: ChatMessageStatsView;
		agenticTimings?: ChatMessageAgenticTimings;
		onActiveViewChange?: (view: ChatMessageStatsView) => void;
		hideSummary?: boolean;
		mode?: ChatMessageStatisticsMode;
	}

	let {
		agenticTimings,
		hideSummary = false,
		initialView = ChatMessageStatsView.GENERATION,
		isLive = false,
		isProcessingPrompt = false,
		mode = ChatMessageStatisticsMode.SWITCHABLE,
		onActiveViewChange,
		predictedMs,
		predictedTokens,
		promptMs,
		promptTokens
	}: Props = $props();

	let isSwitchable = $derived(mode === ChatMessageStatisticsMode.SWITCHABLE);

	let activeView: ChatMessageStatsView = $derived(
		mode === ChatMessageStatisticsMode.READING
			? ChatMessageStatsView.READING
			: mode === ChatMessageStatisticsMode.GENERATION
				? ChatMessageStatsView.GENERATION
				: initialView
	);
	let hasAutoSwitchedToGeneration = $state(false);

	$effect(() => {
		if (isSwitchable) {
			onActiveViewChange?.(activeView);
		}
	});

	// In live mode: auto-switch to GENERATION tab when prompt processing completes
	$effect(() => {
		if (isLive && isSwitchable) {
			// Auto-switch to generation tab only when prompt processing is done (once)
			if (
				!hasAutoSwitchedToGeneration &&
				!isProcessingPrompt &&
				predictedTokens &&
				predictedTokens > 0
			) {
				activeView = ChatMessageStatsView.GENERATION;
				hasAutoSwitchedToGeneration = true;
			} else if (!hasAutoSwitchedToGeneration) {
				// Stay on READING while prompt is still being processed
				activeView = ChatMessageStatsView.READING;
			}
		}
	});

	let hasGenerationStats = $derived(
		predictedTokens !== undefined &&
			predictedTokens > 0 &&
			predictedMs !== undefined &&
			predictedMs > 0
	);

	let tokensPerSecond = $derived(
		hasGenerationStats ? (predictedTokens! / predictedMs!) * MS_PER_SECOND : 0
	);
	let formattedTime = $derived(
		predictedMs !== undefined ? formatPerformanceTime(predictedMs) : DEFAULT_PERFORMANCE_TIME
	);

	let promptTokensPerSecond = $derived(
		promptTokens !== undefined && promptMs !== undefined && promptMs > 0
			? (promptTokens / promptMs) * MS_PER_SECOND
			: undefined
	);

	let formattedPromptTime = $derived(
		promptMs !== undefined ? formatPerformanceTime(promptMs) : undefined
	);

	let hasPromptStats = $derived(
		promptTokens !== undefined &&
			promptMs !== undefined &&
			promptTokensPerSecond !== undefined &&
			formattedPromptTime !== undefined
	);

	let isGenerationDisabled = $derived(isLive && isSwitchable && !hasGenerationStats);

	let hasAgenticStats = $derived(agenticTimings !== undefined && agenticTimings.toolCallsCount > 0);

	let agenticToolsPerSecond = $derived(
		hasAgenticStats && agenticTimings!.toolsMs > 0
			? (agenticTimings!.toolCallsCount / agenticTimings!.toolsMs) * MS_PER_SECOND
			: 0
	);

	let formattedAgenticToolsTime = $derived(
		hasAgenticStats ? formatPerformanceTime(agenticTimings!.toolsMs) : DEFAULT_PERFORMANCE_TIME
	);

	let agenticTotalTimeMs = $derived(
		hasAgenticStats
			? agenticTimings!.toolsMs + agenticTimings!.llm.predicted_ms + agenticTimings!.llm.prompt_ms
			: 0
	);

	let formattedAgenticTotalTime = $derived(formatPerformanceTime(agenticTotalTimeMs));
</script>

{#snippet viewButton(opts: {
	view: ChatMessageStatsView;
	icon: Component;
	label: string;
	tooltipText: string;
	disabled?: boolean;
})}
	{@const IconComponent = opts.icon}
	<Tooltip.Root>
		<Tooltip.Trigger>
			<!-- prevent another nested button element -->
			{#snippet child({ props })}
				<button
					{...props}
					class="inline-flex h-5 w-5 items-center justify-center rounded-sm transition-colors {activeView ===
					opts.view
						? 'bg-background text-foreground shadow-sm'
						: opts.disabled
							? 'cursor-not-allowed opacity-40'
							: 'hover:text-foreground'}"
					disabled={opts.disabled}
					onclick={() => !opts.disabled && (activeView = opts.view)}
					type="button"
				>
					<IconComponent class="h-3 w-3" />

					<span class="sr-only">{opts.label}</span>
				</button>
			{/snippet}
		</Tooltip.Trigger>

		<Tooltip.Content>
			<p>{opts.tooltipText}</p>
		</Tooltip.Content>
	</Tooltip.Root>
{/snippet}

<div class="inline-flex items-center text-xs text-muted-foreground">
	{#if isSwitchable}
		<div class="inline-flex items-center rounded-sm bg-muted-foreground/15 p-0.5">
			{#if hasPromptStats || isLive}
				{@render viewButton({
					icon: BookOpenText,
					label: 'Чтение',
					tooltipText: 'Обработка',
					view: ChatMessageStatsView.READING
				})}
			{/if}

			{@render viewButton({
				disabled: isGenerationDisabled,
				icon: Sparkles,
				label: 'Генерация',
				tooltipText: isGenerationDisabled ? 'Ожидание токенов...' : 'Генерация',
				view: ChatMessageStatsView.GENERATION
			})}

			{#if hasAgenticStats}
				{@render viewButton({
					icon: Wrench,
					label: 'Инструменты',
					tooltipText: 'Вызовы инструментов',
					view: ChatMessageStatsView.TOOLS
				})}

				{#if !hideSummary}
					{@render viewButton({
						icon: Layers,
						label: 'Сводка',
						tooltipText: 'Сводка агента',
						view: ChatMessageStatsView.SUMMARY
					})}
				{/if}
			{/if}
		</div>
	{/if}

	<div class="flex items-center gap-1 px-2">
		{#if activeView === ChatMessageStatsView.GENERATION && hasGenerationStats}
			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={WholeWord}
				tooltipLabel="Сгенерировано токенов"
				value="{predictedTokens?.toLocaleString()} tokens"
			/>

			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Clock}
				tooltipLabel="Время генерации"
				value={formattedTime}
			/>

			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Gauge}
				tooltipLabel="Скорость генерации"
				value="{tokensPerSecond.toFixed(2)} t/s"
			/>
		{:else if activeView === ChatMessageStatsView.TOOLS && hasAgenticStats}
			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Wrench}
				tooltipLabel="Выполнено вызовов инструментов"
				value="{agenticTimings!.toolCallsCount} calls"
			/>

			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Clock}
				tooltipLabel="Время выполнения инструментов"
				value={formattedAgenticToolsTime}
			/>

			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Gauge}
				tooltipLabel="Скорость выполнения инструментов"
				value="{agenticToolsPerSecond.toFixed(2)} calls/s"
			/>
		{:else if activeView === ChatMessageStatsView.SUMMARY && hasAgenticStats}
			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Layers}
				tooltipLabel="Шаги агента (вызовы LLM)"
				value="{agenticTimings!.turns} turns"
			/>

			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={WholeWord}
				tooltipLabel="Всего сгенерировано токенов"
				value="{agenticTimings!.llm.predicted_n.toLocaleString()} токенов"
			/>

			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Clock}
				tooltipLabel="Общее время (LLM + инструменты)"
				value={formattedAgenticTotalTime}
			/>
		{:else if hasPromptStats && (mode === ChatMessageStatisticsMode.READING || isSwitchable)}
			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={WholeWord}
				tooltipLabel="Токенов в запросе"
				value="{promptTokens} tokens"
			/>

			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Clock}
				tooltipLabel="Время обработки запроса"
				value={formattedPromptTime ?? '0s'}
			/>

			<ChatMessageStatisticsBadge
				class="bg-transparent"
				icon={Gauge}
				tooltipLabel="Скорость обработки запроса"
				value="{promptTokensPerSecond!.toFixed(2)} ток/с"
			/>
		{/if}
	</div>
</div>
