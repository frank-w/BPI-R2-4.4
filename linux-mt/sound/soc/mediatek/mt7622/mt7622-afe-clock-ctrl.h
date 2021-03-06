/*
 * mt7622-afe-clock-ctrl.h  --  Mediatek 7622 afe clock ctrl definition
 *
 * Copyright (c) 2016 MediaTek Inc.
 * Author: Garlic Tseng <garlic.tseng@mediatek.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#ifndef _MT7622_AFE_CLOCK_CTRL_H_
#define _MT7622_AFE_CLOCK_CTRL_H_

struct mtk_base_afe;

int mt7622_init_clock(struct mtk_base_afe *afe);
int mt7622_afe_enable_clock(struct mtk_base_afe *afe);
void mt7622_afe_disable_clock(struct mtk_base_afe *afe);

int mt7622_turn_on_a1sys_clock(struct mtk_base_afe *afe);
void mt7622_turn_off_a1sys_clock(struct mtk_base_afe *afe);

int mt7622_turn_on_a2sys_clock(struct mtk_base_afe *afe);
void mt7622_turn_off_a2sys_clock(struct mtk_base_afe *afe);

int mt7622_turn_on_afe_clock(struct mtk_base_afe *afe);
void mt7622_turn_off_afe_clock(struct mtk_base_afe *afe);

void mt7622_i2s_mclk_configuration(struct mtk_base_afe *afe, int id, int domain,
			       int mclk);
void mt7622_tdm_mclk_configuration(struct mtk_base_afe *afe, int tdm_id, int fs);

void mt7622_tdm_clk_configuration(struct mtk_base_afe *afe, int tdm_id,
				  struct snd_pcm_hw_params *params);
#endif
