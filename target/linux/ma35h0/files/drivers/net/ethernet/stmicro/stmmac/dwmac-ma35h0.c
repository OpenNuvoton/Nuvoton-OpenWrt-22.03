// SPDX-License-Identifier: GPL-2.0-only
/**
 * dwmac-ma35h0.c - Nuvoton MA35H0 DWMAC specific glue layer
 * Copyright (C) 2020 Nuvoton Technology Corp.
 *
 */

#include <linux/stmmac.h>
#include <linux/bitops.h>
#include <linux/clk.h>
#include <linux/phy.h>
#include <linux/of_net.h>
#include <linux/module.h>
#include <linux/of_device.h>
#include <linux/platform_device.h>
#include <linux/mfd/syscon.h>
#include <linux/regmap.h>
#include <linux/pm_runtime.h>
#include <linux/mfd/ma35h0-sys.h>
#include "stmmac_platform.h"

#define TXDLY_OFST	16
#define TXDLY_MSK	(0xF << TXDLY_OFST)
#define RXDLY_OFST	20
#define RXDLY_MSK	(0xF << RXDLY_OFST)

struct nvt_priv_data {
	struct platform_device *pdev;
	int id;
	bool suspended;
	struct regmap *regmap;
	phy_interface_t phy_mode;
	int tx_delay;
	int rx_delay;
};

static struct nvt_priv_data *nvt_emac_setup(struct platform_device *pdev,
					    struct plat_stmmacenet_data *plat)
{
	struct nvt_priv_data *bsp_priv;
	struct device *dev = &pdev->dev;
	int value;
	u32 reg;
	int ret;

	bsp_priv = devm_kzalloc(dev, sizeof(*bsp_priv), GFP_KERNEL);
	if (!bsp_priv)
		return ERR_PTR(-ENOMEM);

	if (of_property_read_u32(dev->of_node, "mac-id", &bsp_priv->id) < 0) {
		dev_err(dev, "missing nvt,id property\n");
		return ERR_PTR(-EINVAL);
	}

	bsp_priv->regmap = syscon_regmap_lookup_by_phandle(dev->of_node,
							   "nuvoton,ma35h0-sys");
	if (IS_ERR(bsp_priv->regmap)) {
		dev_err(dev, "Failed to get SYS register\n");
		return ERR_PTR(-ENODEV);
	}

	regmap_read(bsp_priv->regmap,
		    bsp_priv->id == 0 ? REG_SYS_GMAC0MISCR : REG_SYS_GMAC1MISCR, &reg);
	reg &= ~(TXDLY_MSK | RXDLY_MSK);

	ret = of_get_phy_mode(pdev->dev.of_node, &bsp_priv->phy_mode);
	if (ret) {
		dev_err(dev, "missing phy mode property\n");
		return ERR_PTR(-EINVAL);
	}

	switch (bsp_priv->phy_mode) {
	case PHY_INTERFACE_MODE_RGMII:		/* Fall through */
	case PHY_INTERFACE_MODE_RGMII_ID	/* Fall through */:
	case PHY_INTERFACE_MODE_RGMII_RXID:	/* Fall through */
	case PHY_INTERFACE_MODE_RGMII_TXID:
		reg &= ~1;
		break;
	case PHY_INTERFACE_MODE_RMII:
		reg |= 1;
		break;
	default:
		dev_err(dev, "Unsupported phy-mode (%d)\n", bsp_priv->phy_mode);
		return ERR_PTR(-ENOTSUPP);
	}

	if (of_property_read_u32(dev->of_node, "tx_delay", &value)) {
		dev_info(dev, "Set TX delay(0x0).\n");
		bsp_priv->tx_delay = 0x0;
	} else {
		dev_info(dev, "Set TX delay(0x%x).\n", value);
		bsp_priv->tx_delay = value;
		reg |= value << TXDLY_OFST;
	}

	if (of_property_read_u32(dev->of_node, "rx_delay", &value)) {
		dev_info(dev, "Set RX delay(0x0).\n");
		bsp_priv->rx_delay = 0x0;
	} else {
		dev_info(dev, "Set RX delay(0x%x).\n", value);
		bsp_priv->rx_delay = value;
		reg |= value << RXDLY_OFST;
	}

	regmap_write(bsp_priv->regmap,
		     bsp_priv->id == 0 ? REG_SYS_GMAC0MISCR : REG_SYS_GMAC1MISCR, reg);

	bsp_priv->pdev = pdev;

	return bsp_priv;
}

static int nvt_emac_probe(struct platform_device *pdev)
{
	struct plat_stmmacenet_data *plat_dat;
	struct stmmac_resources stmmac_res;
	int ret;

	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
	if (ret)
		return ret;

	plat_dat = stmmac_probe_config_dt(pdev, stmmac_res.mac);
	if (IS_ERR(plat_dat))
		return PTR_ERR(plat_dat);

	plat_dat->has_gmac = 1;
	plat_dat->pmt = 1;

	plat_dat->bsp_priv = nvt_emac_setup(pdev, plat_dat);
	if (IS_ERR(plat_dat->bsp_priv)) {
		ret = PTR_ERR(plat_dat->bsp_priv);
		goto err_remove_config_dt;
	}

	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
	if (ret)
		goto err_remove_config_dt;

	return 0;

err_remove_config_dt:
	stmmac_remove_config_dt(pdev, plat_dat);

	return ret;
}

static int nvt_emac_remove(struct platform_device *pdev)
{
	int ret = stmmac_dvr_remove(&pdev->dev);

	return ret;
}

#ifdef CONFIG_PM_SLEEP
static int nvt_emac_suspend(struct device *dev)
{
	//struct nvt_priv_data *bsp_priv = get_stmmac_bsp_priv(dev);
	int ret = stmmac_suspend(dev);

	return ret;
}

static int nvt_emac_resume(struct device *dev)
{
	//struct nvt_priv_data *bsp_priv = get_stmmac_bsp_priv(dev);

	return stmmac_resume(dev);
}
#endif /* CONFIG_PM_SLEEP */

static SIMPLE_DEV_PM_OPS(nvt_emac_pm_ops, nvt_emac_suspend, nvt_emac_resume);

static const struct of_device_id nvt_emac_dwmac_match[] = {
	{ .compatible = "nuvoton,ma35h0-emac"},
	{ }
};
MODULE_DEVICE_TABLE(of, nvt_emac_dwmac_match);

static struct platform_driver nvt_emac_dwmac_driver = {
	.probe  = nvt_emac_probe,
	.remove = nvt_emac_remove,
	.driver = {
		.name           = "ma35h0-emac",
		.pm		= &nvt_emac_pm_ops,
		.of_match_table = nvt_emac_dwmac_match,
	},
};
module_platform_driver(nvt_emac_dwmac_driver);

MODULE_DESCRIPTION("Nuvoton MA35H0 DWMAC specific glue layer");
MODULE_LICENSE("GPL v2");
