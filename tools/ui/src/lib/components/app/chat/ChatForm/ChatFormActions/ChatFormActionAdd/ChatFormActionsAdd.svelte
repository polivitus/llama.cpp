<script lang="ts">
	import { Paperclip } from '@lucide/svelte';
	import { Button } from '$lib/components/ui/button';
	import * as Tooltip from '$lib/components/ui/tooltip';
	import { ICON_CLASS_DEFAULT, USER_MODE } from '$lib/constants';
	import { getChatFormActionsContext } from '$lib/contexts';
	import { deviceStore } from '$lib/stores';
	import ChatFormActionAddButton from './ChatFormActionAddButton.svelte';
	import ChatFormActionAddDropdown from './ChatFormActionAddDropdown.svelte';
	import ChatFormActionAddSheet from './ChatFormActionAddSheet.svelte';

	const chatFormActions = getChatFormActionsContext();

	const USER_TOOLTIP = 'Добавить документы, фото или промпты, размер не более 10 МБ';
</script>

{#if USER_MODE}
	<!-- User-mode: скрепка с tooltip — прямая загрузка файлов -->
	<Tooltip.Root>
		<Tooltip.Trigger class="w-full">
			<Button
				class="file-upload-button md:h-8 md:w-8 h-9 w-9 rounded-full p-0"
				onclick={() => chatFormActions.onFileUpload?.()}
				type="button"
				variant="secondary"
			>
				<span class="sr-only">{USER_TOOLTIP}</span>
				<Paperclip class={ICON_CLASS_DEFAULT} />
			</Button>
		</Tooltip.Trigger>

		<Tooltip.Content>
			<p>{USER_TOOLTIP}</p>
		</Tooltip.Content>
	</Tooltip.Root>
{:else if deviceStore.isMobile}
	<ChatFormActionAddSheet>
		{#snippet trigger({ disabled, onclick })}
			<ChatFormActionAddButton {disabled} {onclick} />
		{/snippet}
	</ChatFormActionAddSheet>
{:else}
	<ChatFormActionAddDropdown />
{/if}
