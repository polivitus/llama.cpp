<script lang="ts">
	import ActionIcon from './ActionIcon.svelte';
	import { Copy } from '@lucide/svelte';
	import { ICON_CLASS_DEFAULT } from '$lib/constants';
	import { copyToClipboard } from '$lib/utils';
	import { TooltipSide } from '$lib/enums';

	export let ariaLabel: string = 'Копировать в буфер';
	export let canCopy: boolean = true;
	export let text: string;
	export let tooltipSide: TooltipSide = TooltipSide.LEFT;
</script>

<ActionIcon
	disabled={!canCopy}
	icon={Copy}
	iconSize={ICON_CLASS_DEFAULT}
	onclick={() => canCopy && copyToClipboard(text)}
	tooltip={ariaLabel}
	{tooltipSide}
/>
