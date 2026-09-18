<script lang="ts">
	import { ArrowRight, Copy, Download, Edit, GitBranch, RefreshCw, Trash2 } from '@lucide/svelte';
	import {
		ActionIcon,
		ChatMessageActionIconsBranchingControls,
		DialogConfirmation
	} from '$lib/components/app';
	import { Checkbox } from '$lib/components/ui/checkbox';
	import Input from '$lib/components/ui/input/input.svelte';
	import Label from '$lib/components/ui/label/label.svelte';
	import { Switch } from '$lib/components/ui/switch';
	import { getChatMessageActionsContext, getChatMessageEditContext } from '$lib/contexts';
	import { MessageRole } from '$lib/enums';
	import { conversationsStore } from '$lib/stores';
	import type { DatabaseMessage } from '$lib/types';
	import { USER_MODE } from '$lib/constants';

	interface Props {
		message?: DatabaseMessage;
		role: MessageRole.USER | MessageRole.ASSISTANT;
		justify: 'start' | 'end';
		actionsPosition: 'left' | 'right';
		onRegenerate?: () => void;
		onContinue?: () => void;
		showRawOutputSwitch?: boolean;
		rawOutputEnabled?: boolean;
		onRawOutputToggle?: (enabled: boolean) => void;
	}

	let {
		actionsPosition,
		justify,
		message,
		onContinue,
		onRawOutputToggle,
		onRegenerate,
		rawOutputEnabled = false,
		role,
		showRawOutputSwitch = false
	}: Props = $props();

	const messageActions = getChatMessageActionsContext();
	const editCtx = getChatMessageEditContext();

	const isUser = $derived(role === MessageRole.USER);
	const isAssistant = $derived(role === MessageRole.ASSISTANT);

	const showEdit = $derived(!USER_MODE || isUser);
	const showRegenerate = $derived(isAssistant && !!onRegenerate);
	const showContinue = $derived(isAssistant && !!onContinue && !USER_MODE);
	const showFork = $derived(!!messageActions.forkConversation && !USER_MODE);
	const showDelete = $derived(!USER_MODE);

	let showForkDialog = $state(false);
	let forkName = $state('');
	let forkIncludeAttachments = $state(true);

	function handleDownload() {
		if (!message) return;
		const now = new Date();
		const ts = now.toISOString().slice(0, 16).replace('T', '-').replace(':', '-');
		let text = `Ответ ассистента\n${'='.repeat(30)}\n\n`;
		text += `Модель: ${message.model ?? 'неизвестно'}\n`;
		text += `Дата: ${now.toLocaleString()}\n`;
		if (message.timings) {
			text += `Токенов: ${message.timings.predicted_n ?? '?'}\n`;
			text += `Время: ${message.timings.predicted_ms ?? '?'} мс\n`;
		}
		text += `\nКонтент\n${'-'.repeat(30)}\n\n${message.content ?? ''}\n`;
		if (message.reasoningContent) {
			text += `\nReasoning\n${'-'.repeat(30)}\n\n${message.reasoningContent}\n`;
		}
		const blob = new Blob([text], { type: 'text/plain;charset=utf-8' });
		const url = URL.createObjectURL(blob);
		const a = document.createElement('a');
		a.href = url;
		a.download = `ответ-${ts}.txt`;
		a.click();
		URL.revokeObjectURL(url);
	}

	function handleConfirmDelete() {
		messageActions.confirmDelete();
		messageActions.setShowDeleteDialog(false);
	}

	function handleOpenForkDialog() {
		const conv = conversationsStore.activeConversation;

		forkName = `Ответвление от ${conv?.name ?? 'Conversation'}`;
		forkIncludeAttachments = true;
		showForkDialog = true;
	}

	function handleConfirmFork() {
		messageActions.forkConversation?.({
			includeAttachments: forkIncludeAttachments,
			name: forkName.trim()
		});
		showForkDialog = false;
	}
</script>

<div class="relative {justify === 'start' ? 'mt-2' : ''} flex h-6 items-center justify-between">
	<div
		class="{actionsPosition === 'left'
			? 'left-0'
			: 'right-0'} flex items-center gap-2 opacity-100 transition-opacity"
	>
		{#if messageActions.siblingInfo && messageActions.siblingInfo.totalSiblings > 1}
			<ChatMessageActionIconsBranchingControls />
		{/if}

		<div
			class="pointer-events-auto inset-0 flex items-center gap-1 opacity-100 transition-all duration-150"
		>
			<ActionIcon icon={Copy} onclick={messageActions.copy} tooltip="Копировать" />

			{#if showEdit}
				<ActionIcon icon={Edit} onclick={editCtx.startEdit} tooltip="Редактировать" />
			{/if}

			{#if showRegenerate}
				<ActionIcon icon={RefreshCw} onclick={() => onRegenerate?.()} tooltip="Перегенерировать" />
			{/if}

			{#if USER_MODE && isAssistant && message}
				<ActionIcon icon={Download} onclick={handleDownload} tooltip="Скачать ответ" />
			{/if}

			{#if showContinue}
				<ActionIcon icon={ArrowRight} onclick={onContinue} tooltip="Продолжить" />
			{/if}

			{#if showFork}
				<ActionIcon icon={GitBranch} onclick={handleOpenForkDialog} tooltip="Разветвить беседу" />
			{/if}

			{#if showDelete}
				<ActionIcon icon={Trash2} onclick={messageActions.requestDelete} tooltip="Удалить" />
			{/if}
		</div>
	</div>

	{#if showRawOutputSwitch}
		<div class="flex items-center gap-2">
			<span class="text-xs text-muted-foreground">Show raw output</span>

			<Switch
				checked={rawOutputEnabled}
				onCheckedChange={(checked) => onRawOutputToggle?.(checked)}
			/>
		</div>
	{/if}
</div>

<DialogConfirmation
	cancelText="Отмена"
	confirmText={messageActions.deletionInfo && messageActions.deletionInfo.totalCount > 1
		? `Удалить ${messageActions.deletionInfo.totalCount} сообщений`
		: 'Удалить'}
	description={messageActions.deletionInfo && messageActions.deletionInfo.totalCount > 1
		? `Будет удалено ${messageActions.deletionInfo.totalCount} сообщений: ${messageActions.deletionInfo.userMessages} от пользователя и ${messageActions.deletionInfo.assistantMessages} от ассистента. Все сообщения в этой ветке и их ответы будут безвозвратно удалены. Это действие нельзя отменить.`
		: 'Вы уверены, что хотите удалить это сообщение? Это действие нельзя отменить.'}
	icon={Trash2}
	onCancel={() => messageActions.setShowDeleteDialog(false)}
	onConfirm={handleConfirmDelete}
	open={messageActions.showDeleteDialog}
	title="Удалить сообщение"
	variant="destructive"
/>

<DialogConfirmation
	bind:open={showForkDialog}
	cancelText="Отмена"
	confirmText="Разветвить"
	description="Создать новую беседу, ответвляющуюся от этого сообщения."
	icon={GitBranch}
	onCancel={() => (showForkDialog = false)}
	onConfirm={handleConfirmFork}
	title="Разветвить беседу"
>
	<div class="flex flex-col gap-4 py-2">
		<div class="flex flex-col gap-2">
			<Label for="fork-name">Название</Label>

			<Input
				bind:value={forkName}
				class="text-foreground"
				id="fork-name"
				placeholder="Введите название ветки"
				type="text"
			/>
		</div>

		<div class="flex items-center gap-2">
			<Checkbox
				checked={forkIncludeAttachments}
				id="fork-attachments"
				onCheckedChange={(checked) => {
					forkIncludeAttachments = checked === true;
				}}
			/>

			<Label class="cursor-pointer text-sm font-normal" for="fork-attachments">
				Включить все вложения
			</Label>
		</div>
	</div>
</DialogConfirmation>
