--  First change change

CREATE OR REPLACE VIEW c_invoice_linetax_v AS
  SELECT il.ad_client_id,
    il.ad_org_id,
    il.isactive,
    il.created,
    il.createdby,
    il.updated,
    il.updatedby,
    'en_US'::text AS ad_language,
    il.c_invoice_id,
    il.c_invoiceline_id,
    il.c_tax_id,
    il.taxamt,
    il.linetotalamt,
    t.taxindicator,
    il.line,
    p.m_product_id,
    CASE
    WHEN ((il.qtyinvoiced <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.qtyinvoiced
    ELSE NULL::numeric
    END AS qtyinvoiced,
    CASE
    WHEN ((il.qtyentered <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.qtyentered
    ELSE NULL::numeric
    END AS qtyentered,
    CASE
    WHEN ((il.qtyentered <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN uom.uomsymbol
    ELSE NULL::character varying
    END AS uomsymbol,
    COALESCE(c.name, (((p.name)::text))::character varying, il.description) AS name,
    CASE
    WHEN (COALESCE(c.name, p.name) IS NOT NULL) THEN il.description
    ELSE NULL::character varying
    END AS description,
    p.documentnote,
    p.upc,
    p.sku,
    COALESCE(pp.vendorproductno, p.value) AS productvalue,
    ra.description AS resourcedescription,
    CASE
    WHEN ((i.isdiscountprinted = 'Y'::bpchar) AND (il.pricelist <> (0)::numeric)) THEN il.pricelist
    ELSE NULL::numeric
    END AS pricelist,
    CASE
    WHEN ((i.isdiscountprinted = 'Y'::bpchar) AND (il.pricelist <> (0)::numeric) AND (il.qtyentered <> (0)::numeric)) THEN ((il.pricelist * il.qtyinvoiced) / il.qtyentered)
    ELSE NULL::numeric
    END AS priceenteredlist,
    CASE
    WHEN ((i.isdiscountprinted = 'Y'::bpchar) AND (il.pricelist > il.priceactual) AND (il.pricelist <> (0)::numeric)) THEN (((il.pricelist - il.priceactual) / il.pricelist) * (100)::numeric)
    ELSE NULL::numeric
    END AS discount,
    CASE
    WHEN ((il.priceactual <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.priceactual
    ELSE NULL::numeric
    END AS priceactual,
    CASE
    WHEN ((il.priceentered <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.priceentered
    ELSE NULL::numeric
    END AS priceentered,
    CASE
    WHEN ((il.linenetamt <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.linenetamt
    ELSE NULL::numeric
    END AS linenetamt,
    il.m_attributesetinstance_id,
    asi.m_attributeset_id,
    asi.serno,
    asi.lot,
    asi.m_lot_id,
    asi.guaranteedate,
    p.description AS productdescription,
    p.imageurl,
    il.c_campaign_id,
    il.c_project_id,
    il.c_activity_id,
    il.c_projectphase_id,
    il.c_projecttask_id
  FROM ((((((((c_invoiceline il
    JOIN c_uom uom ON ((il.c_uom_id = uom.c_uom_id)))
    JOIN c_invoice i ON ((il.c_invoice_id = i.c_invoice_id)))
    LEFT JOIN c_tax t ON ((il.c_tax_id = t.c_tax_id)))
    LEFT JOIN m_product p ON ((il.m_product_id = p.m_product_id)))
    LEFT JOIN c_charge c ON ((il.c_charge_id = c.c_charge_id)))
    LEFT JOIN c_bpartner_product pp ON (((il.m_product_id = pp.m_product_id) AND (i.c_bpartner_id = pp.c_bpartner_id))))
    LEFT JOIN s_resourceassignment ra ON ((il.s_resourceassignment_id = ra.s_resourceassignment_id)))
    LEFT JOIN m_attributesetinstance asi ON ((il.m_attributesetinstance_id = asi.m_attributesetinstance_id)))
  UNION
  SELECT il.ad_client_id,
    il.ad_org_id,
    il.isactive,
    il.created,
    il.createdby,
    il.updated,
    il.updatedby,
    'en_US'::text AS ad_language,
    il.c_invoice_id,
    il.c_invoiceline_id,
    il.c_tax_id,
    il.taxamt,
    il.linetotalamt,
    t.taxindicator,
    (il.line + (bl.line / (100)::numeric)) AS line,
    p.m_product_id,
    CASE
    WHEN (bl.isqtypercentage = 'N'::bpchar) THEN (il.qtyinvoiced * bl.qtybom)
    ELSE (il.qtyinvoiced * (bl.qtybatch / (100)::numeric))
    END AS qtyinvoiced,
    CASE
    WHEN (bl.isqtypercentage = 'N'::bpchar) THEN (il.qtyentered * bl.qtybom)
    ELSE (il.qtyentered * (bl.qtybatch / (100)::numeric))
    END AS qtyentered,
    uom.uomsymbol,
    p.name,
    b.description,
    p.documentnote,
    p.upc,
    p.sku,
    p.value AS productvalue,
    NULL::character varying AS resourcedescription,
    NULL::numeric AS pricelist,
    NULL::numeric AS priceenteredlist,
    NULL::numeric AS discount,
    NULL::numeric AS priceactual,
    NULL::numeric AS priceentered,
    NULL::numeric AS linenetamt,
    il.m_attributesetinstance_id,
    asi.m_attributeset_id,
    asi.serno,
    asi.lot,
    asi.m_lot_id,
    asi.guaranteedate,
    p.description AS productdescription,
    p.imageurl,
    il.c_campaign_id,
    il.c_project_id,
    il.c_activity_id,
    il.c_projectphase_id,
    il.c_projecttask_id
  FROM (((((((pp_product_bom b
    JOIN c_invoiceline il ON ((b.m_product_id = il.m_product_id)))
    JOIN m_product bp ON (((bp.m_product_id = il.m_product_id) AND (bp.isbom = 'Y'::bpchar) AND (bp.isverified = 'Y'::bpchar) AND (bp.isinvoiceprintdetails = 'Y'::bpchar))))
    JOIN pp_product_bomline bl ON ((bl.pp_product_bom_id = b.pp_product_bom_id)))
    JOIN m_product p ON ((bl.m_product_id = p.m_product_id)))
    JOIN c_uom uom ON ((p.c_uom_id = uom.c_uom_id)))
    LEFT JOIN c_tax t ON ((il.c_tax_id = t.c_tax_id)))
    LEFT JOIN m_attributesetinstance asi ON ((il.m_attributesetinstance_id = asi.m_attributesetinstance_id)))
  UNION
  SELECT il.ad_client_id,
    il.ad_org_id,
    il.isactive,
    il.created,
    il.createdby,
    il.updated,
    il.updatedby,
    'en_US'::text AS ad_language,
    il.c_invoice_id,
    il.c_invoiceline_id,
    NULL::numeric AS c_tax_id,
    NULL::numeric AS taxamt,
    NULL::numeric AS linetotalamt,
    NULL::character varying AS taxindicator,
    il.line,
    NULL::numeric AS m_product_id,
    NULL::numeric AS qtyinvoiced,
    NULL::numeric AS qtyentered,
    NULL::character varying AS uomsymbol,
    il.description AS name,
    NULL::character varying AS description,
    NULL::character varying AS documentnote,
    NULL::character varying AS upc,
    NULL::character varying AS sku,
    NULL::character varying AS productvalue,
    NULL::character varying AS resourcedescription,
    NULL::numeric AS pricelist,
    NULL::numeric AS priceenteredlist,
    NULL::numeric AS discount,
    NULL::numeric AS priceactual,
    NULL::numeric AS priceentered,
    NULL::numeric AS linenetamt,
    NULL::numeric AS m_attributesetinstance_id,
    NULL::numeric AS m_attributeset_id,
    NULL::character varying AS serno,
    NULL::character varying AS lot,
    NULL::numeric AS m_lot_id,
    NULL::timestamp without time zone AS guaranteedate,
    NULL::character varying AS productdescription,
    NULL::character varying AS imageurl,
    NULL::numeric AS c_campaign_id,
    NULL::numeric AS c_project_id,
    NULL::numeric AS c_activity_id,
    NULL::numeric AS c_projectphase_id,
    NULL::numeric AS c_projecttask_id
  FROM c_invoiceline il
  WHERE (il.c_uom_id IS NULL)
  UNION
  SELECT c_invoice.ad_client_id,
    c_invoice.ad_org_id,
    c_invoice.isactive,
    c_invoice.created,
    c_invoice.createdby,
    c_invoice.updated,
    c_invoice.updatedby,
    'en_US'::text AS ad_language,
    c_invoice.c_invoice_id,
    NULL::numeric AS c_invoiceline_id,
    NULL::numeric AS c_tax_id,
    NULL::numeric AS taxamt,
    NULL::numeric AS linetotalamt,
    NULL::character varying AS taxindicator,
    999998 AS line,
    NULL::numeric AS m_product_id,
    NULL::numeric AS qtyinvoiced,
    NULL::numeric AS qtyentered,
    NULL::character varying AS uomsymbol,
    NULL::character varying AS name,
    NULL::character varying AS description,
    NULL::character varying AS documentnote,
    NULL::character varying AS upc,
    NULL::character varying AS sku,
    NULL::character varying AS productvalue,
    NULL::character varying AS resourcedescription,
    NULL::numeric AS pricelist,
    NULL::numeric AS priceenteredlist,
    NULL::numeric AS discount,
    NULL::numeric AS priceactual,
    NULL::numeric AS priceentered,
    NULL::numeric AS linenetamt,
    NULL::numeric AS m_attributesetinstance_id,
    NULL::numeric AS m_attributeset_id,
    NULL::character varying AS serno,
    NULL::character varying AS lot,
    NULL::numeric AS m_lot_id,
    NULL::timestamp without time zone AS guaranteedate,
    NULL::character varying AS productdescription,
    NULL::character varying AS imageurl,
    NULL::numeric AS c_campaign_id,
    NULL::numeric AS c_project_id,
    NULL::numeric AS c_activity_id,
    NULL::numeric AS c_projectphase_id,
    NULL::numeric AS c_projecttask_id
  FROM c_invoice
  UNION
  SELECT it.ad_client_id,
    it.ad_org_id,
    it.isactive,
    it.created,
    it.createdby,
    it.updated,
    it.updatedby,
    'en_US'::text AS ad_language,
    it.c_invoice_id,
    NULL::numeric AS c_invoiceline_id,
    it.c_tax_id,
    NULL::numeric AS taxamt,
    NULL::numeric AS linetotalamt,
    t.taxindicator,
    999999 AS line,
    NULL::numeric AS m_product_id,
    NULL::numeric AS qtyinvoiced,
    NULL::numeric AS qtyentered,
    NULL::character varying AS uomsymbol,
    t.name,
    NULL::character varying AS description,
    NULL::character varying AS documentnote,
    NULL::character varying AS upc,
    NULL::character varying AS sku,
    NULL::character varying AS productvalue,
    NULL::character varying AS resourcedescription,
    NULL::numeric AS pricelist,
    NULL::numeric AS priceenteredlist,
    NULL::numeric AS discount,
    CASE
    WHEN (it.istaxincluded = 'Y'::bpchar) THEN it.taxamt
    ELSE it.taxbaseamt
    END AS priceactual,
    CASE
    WHEN (it.istaxincluded = 'Y'::bpchar) THEN it.taxamt
    ELSE it.taxbaseamt
    END AS priceentered,
    CASE
    WHEN (it.istaxincluded = 'Y'::bpchar) THEN NULL::numeric
    ELSE it.taxamt
    END AS linenetamt,
    NULL::numeric AS m_attributesetinstance_id,
    NULL::numeric AS m_attributeset_id,
    NULL::character varying AS serno,
    NULL::character varying AS lot,
    NULL::numeric AS m_lot_id,
    NULL::timestamp without time zone AS guaranteedate,
    NULL::character varying AS productdescription,
    NULL::character varying AS imageurl,
    NULL::numeric AS c_campaign_id,
    NULL::numeric AS c_project_id,
    NULL::numeric AS c_activity_id,
    NULL::numeric AS c_projectphase_id,
    NULL::numeric AS c_projecttask_id
  FROM (c_invoicetax it
    JOIN c_tax t ON ((it.c_tax_id = t.c_tax_id)));

CREATE OR REPLACE VIEW c_invoice_linetax_vt AS
  SELECT il.ad_client_id,
    il.ad_org_id,
    il.isactive,
    il.created,
    il.createdby,
    il.updated,
    il.updatedby,
    uom.ad_language,
    il.c_invoice_id,
    il.c_invoiceline_id,
    il.c_tax_id,
    il.taxamt,
    il.linetotalamt,
    t.taxindicator,
    il.line,
    p.m_product_id,
    CASE
    WHEN ((il.qtyinvoiced <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.qtyinvoiced
    ELSE NULL::numeric
    END AS qtyinvoiced,
    CASE
    WHEN ((il.qtyentered <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.qtyentered
    ELSE NULL::numeric
    END AS qtyentered,
    CASE
    WHEN ((il.qtyentered <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN uom.uomsymbol
    ELSE NULL::character varying
    END AS uomsymbol,
    COALESCE(c.name, (COALESCE(pt.name, p.name)::text)::character varying, il.description) AS name,
    CASE
    WHEN (COALESCE(c.name, pt.name, p.name) IS NOT NULL) THEN il.description
    ELSE NULL::character varying
    END AS description,
    COALESCE(pt.documentnote, p.documentnote) AS documentnote,
    p.upc,
    p.sku,
    COALESCE(pp.vendorproductno, p.value) AS productvalue,
    ra.description AS resourcedescription,
    CASE
    WHEN ((i.isdiscountprinted = 'Y'::bpchar) AND (il.pricelist <> (0)::numeric)) THEN il.pricelist
    ELSE NULL::numeric
    END AS pricelist,
    CASE
    WHEN ((i.isdiscountprinted = 'Y'::bpchar) AND (il.pricelist <> (0)::numeric) AND (il.qtyentered <> (0)::numeric)) THEN ((il.pricelist * il.qtyinvoiced) / il.qtyentered)
    ELSE NULL::numeric
    END AS priceenteredlist,
    CASE
    WHEN ((i.isdiscountprinted = 'Y'::bpchar) AND (il.pricelist > il.priceactual) AND (il.pricelist <> (0)::numeric)) THEN (((il.pricelist - il.priceactual) / il.pricelist) * (100)::numeric)
    ELSE NULL::numeric
    END AS discount,
    CASE
    WHEN ((il.priceactual <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.priceactual
    ELSE NULL::numeric
    END AS priceactual,
    CASE
    WHEN ((il.priceentered <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.priceentered
    ELSE NULL::numeric
    END AS priceentered,
    CASE
    WHEN ((il.linenetamt <> (0)::numeric) OR (il.m_product_id IS NOT NULL)) THEN il.linenetamt
    ELSE NULL::numeric
    END AS linenetamt,
    il.m_attributesetinstance_id,
    asi.m_attributeset_id,
    asi.serno,
    asi.lot,
    asi.m_lot_id,
    asi.guaranteedate,
    pt.description AS productdescription,
    p.imageurl,
    il.c_campaign_id,
    il.c_project_id,
    il.c_activity_id,
    il.c_projectphase_id,
    il.c_projecttask_id
  FROM (((((((((c_invoiceline il
    JOIN c_uom_trl uom ON ((il.c_uom_id = uom.c_uom_id)))
    JOIN c_invoice i ON ((il.c_invoice_id = i.c_invoice_id)))
    LEFT JOIN c_tax_trl t ON (((il.c_tax_id = t.c_tax_id) AND ((uom.ad_language)::text = (t.ad_language)::text))))
    LEFT JOIN m_product p ON ((il.m_product_id = p.m_product_id)))
    LEFT JOIN c_charge_trl c ON ((il.c_charge_id = c.c_charge_id)))
    LEFT JOIN c_bpartner_product pp ON (((il.m_product_id = pp.m_product_id) AND (i.c_bpartner_id = pp.c_bpartner_id))))
    LEFT JOIN m_product_trl pt ON (((il.m_product_id = pt.m_product_id) AND ((uom.ad_language)::text = (pt.ad_language)::text))))
    LEFT JOIN s_resourceassignment ra ON ((il.s_resourceassignment_id = ra.s_resourceassignment_id)))
    LEFT JOIN m_attributesetinstance asi ON ((il.m_attributesetinstance_id = asi.m_attributesetinstance_id)))
  UNION
  SELECT il.ad_client_id,
    il.ad_org_id,
    il.isactive,
    il.created,
    il.createdby,
    il.updated,
    il.updatedby,
    uom.ad_language,
    il.c_invoice_id,
    il.c_invoiceline_id,
    il.c_tax_id,
    il.taxamt,
    il.linetotalamt,
    t.taxindicator,
    (il.line + (bl.line / (100)::numeric)) AS line,
    p.m_product_id,
    CASE
    WHEN (bl.isqtypercentage = 'N'::bpchar) THEN (il.qtyinvoiced * bl.qtybom)
    ELSE (il.qtyinvoiced * (bl.qtybatch / (100)::numeric))
    END AS qtyinvoiced,
    CASE
    WHEN (bl.isqtypercentage = 'N'::bpchar) THEN (il.qtyentered * bl.qtybom)
    ELSE (il.qtyentered * (bl.qtybatch / (100)::numeric))
    END AS qtyentered,
    uom.uomsymbol,
    COALESCE(pt.name, p.name) AS name,
    b.description,
    COALESCE(pt.documentnote, p.documentnote) AS documentnote,
    p.upc,
    p.sku,
    p.value AS productvalue,
    NULL::character varying AS resourcedescription,
    NULL::numeric AS pricelist,
    NULL::numeric AS priceenteredlist,
    NULL::numeric AS discount,
    NULL::numeric AS priceactual,
    NULL::numeric AS priceentered,
    NULL::numeric AS linenetamt,
    il.m_attributesetinstance_id,
    asi.m_attributeset_id,
    asi.serno,
    asi.lot,
    asi.m_lot_id,
    asi.guaranteedate,
    pt.description AS productdescription,
    p.imageurl,
    il.c_campaign_id,
    il.c_project_id,
    il.c_activity_id,
    il.c_projectphase_id,
    il.c_projecttask_id
  FROM ((((((((pp_product_bom b
    JOIN c_invoiceline il ON ((b.m_product_id = il.m_product_id)))
    JOIN m_product bp ON (((bp.m_product_id = il.m_product_id) AND (bp.isbom = 'Y'::bpchar) AND (bp.isverified = 'Y'::bpchar) AND (bp.isinvoiceprintdetails = 'Y'::bpchar))))
    JOIN pp_product_bomline bl ON ((bl.pp_product_bom_id = b.pp_product_bom_id)))
    JOIN m_product p ON ((bl.m_product_id = p.m_product_id)))
    JOIN c_uom_trl uom ON ((p.c_uom_id = uom.c_uom_id)))
    JOIN m_product_trl pt ON (((bl.m_product_id = pt.m_product_id) AND ((uom.ad_language)::text = (pt.ad_language)::text))))
    LEFT JOIN c_tax t ON ((il.c_tax_id = t.c_tax_id)))
    LEFT JOIN m_attributesetinstance asi ON ((il.m_attributesetinstance_id = asi.m_attributesetinstance_id)))
  UNION
  SELECT il.ad_client_id,
    il.ad_org_id,
    il.isactive,
    il.created,
    il.createdby,
    il.updated,
    il.updatedby,
    l.ad_language,
    il.c_invoice_id,
    il.c_invoiceline_id,
    NULL::numeric AS c_tax_id,
    NULL::numeric AS taxamt,
    NULL::numeric AS linetotalamt,
    NULL::character varying AS taxindicator,
    il.line,
    NULL::numeric AS m_product_id,
    NULL::numeric AS qtyinvoiced,
    NULL::numeric AS qtyentered,
    NULL::character varying AS uomsymbol,
    il.description AS name,
    NULL::character varying AS description,
    NULL::character varying AS documentnote,
    NULL::character varying AS upc,
    NULL::character varying AS sku,
    NULL::character varying AS productvalue,
    NULL::character varying AS resourcedescription,
    NULL::numeric AS pricelist,
    NULL::numeric AS priceenteredlist,
    NULL::numeric AS discount,
    NULL::numeric AS priceactual,
    NULL::numeric AS priceentered,
    NULL::numeric AS linenetamt,
    NULL::numeric AS m_attributesetinstance_id,
    NULL::numeric AS m_attributeset_id,
    NULL::character varying AS serno,
    NULL::character varying AS lot,
    NULL::numeric AS m_lot_id,
    NULL::timestamp without time zone AS guaranteedate,
    NULL::character varying AS productdescription,
    NULL::character varying AS imageurl,
    NULL::numeric AS c_campaign_id,
    NULL::numeric AS c_project_id,
    NULL::numeric AS c_activity_id,
    NULL::numeric AS c_projectphase_id,
    NULL::numeric AS c_projecttask_id
  FROM c_invoiceline il,
    ad_language l
  WHERE ((il.c_uom_id IS NULL) AND (l.isbaselanguage = 'N'::bpchar) AND (l.issystemlanguage = 'Y'::bpchar))
  UNION
  SELECT i.ad_client_id,
    i.ad_org_id,
    i.isactive,
    i.created,
    i.createdby,
    i.updated,
    i.updatedby,
    l.ad_language,
    i.c_invoice_id,
    NULL::numeric AS c_invoiceline_id,
    NULL::numeric AS c_tax_id,
    NULL::numeric AS taxamt,
    NULL::numeric AS linetotalamt,
    NULL::character varying AS taxindicator,
    999998 AS line,
    NULL::numeric AS m_product_id,
    NULL::numeric AS qtyinvoiced,
    NULL::numeric AS qtyentered,
    NULL::character varying AS uomsymbol,
    NULL::character varying AS name,
    NULL::character varying AS description,
    NULL::character varying AS documentnote,
    NULL::character varying AS upc,
    NULL::character varying AS sku,
    NULL::character varying AS productvalue,
    NULL::character varying AS resourcedescription,
    NULL::numeric AS pricelist,
    NULL::numeric AS priceenteredlist,
    NULL::numeric AS discount,
    NULL::numeric AS priceactual,
    NULL::numeric AS priceentered,
    NULL::numeric AS linenetamt,
    NULL::numeric AS m_attributesetinstance_id,
    NULL::numeric AS m_attributeset_id,
    NULL::character varying AS serno,
    NULL::character varying AS lot,
    NULL::numeric AS m_lot_id,
    NULL::timestamp without time zone AS guaranteedate,
    NULL::character varying AS productdescription,
    NULL::character varying AS imageurl,
    NULL::numeric AS c_campaign_id,
    NULL::numeric AS c_project_id,
    NULL::numeric AS c_activity_id,
    NULL::numeric AS c_projectphase_id,
    NULL::numeric AS c_projecttask_id
  FROM c_invoice i,
    ad_language l
  WHERE ((l.isbaselanguage = 'N'::bpchar) AND (l.issystemlanguage = 'Y'::bpchar))
  UNION
  SELECT it.ad_client_id,
    it.ad_org_id,
    it.isactive,
    it.created,
    it.createdby,
    it.updated,
    it.updatedby,
    t.ad_language,
    it.c_invoice_id,
    NULL::numeric AS c_invoiceline_id,
    it.c_tax_id,
    NULL::numeric AS taxamt,
    NULL::numeric AS linetotalamt,
    t.taxindicator,
    999999 AS line,
    NULL::numeric AS m_product_id,
    NULL::numeric AS qtyinvoiced,
    NULL::numeric AS qtyentered,
    NULL::character varying AS uomsymbol,
    t.name,
    NULL::character varying AS description,
    NULL::character varying AS documentnote,
    NULL::character varying AS upc,
    NULL::character varying AS sku,
    NULL::character varying AS productvalue,
    NULL::character varying AS resourcedescription,
    NULL::numeric AS pricelist,
    NULL::numeric AS priceenteredlist,
    NULL::numeric AS discount,
    CASE
    WHEN (it.istaxincluded = 'Y'::bpchar) THEN it.taxamt
    ELSE it.taxbaseamt
    END AS priceactual,
    CASE
    WHEN (it.istaxincluded = 'Y'::bpchar) THEN it.taxamt
    ELSE it.taxbaseamt
    END AS priceentered,
    CASE
    WHEN (it.istaxincluded = 'Y'::bpchar) THEN NULL::numeric
    ELSE it.taxamt
    END AS linenetamt,
    NULL::numeric AS m_attributesetinstance_id,
    NULL::numeric AS m_attributeset_id,
    NULL::character varying AS serno,
    NULL::character varying AS lot,
    NULL::numeric AS m_lot_id,
    NULL::timestamp without time zone AS guaranteedate,
    NULL::character varying AS productdescription,
    NULL::character varying AS imageurl,
    NULL::numeric AS c_campaign_id,
    NULL::numeric AS c_project_id,
    NULL::numeric AS c_activity_id,
    NULL::numeric AS c_projectphase_id,
    NULL::numeric AS c_projecttask_id
  FROM (c_invoicetax it
    JOIN c_tax_trl t ON ((it.c_tax_id = t.c_tax_id)));


CREATE OR REPLACE VIEW m_inout_line_v AS
  SELECT iol.ad_client_id,
    iol.ad_org_id,
    iol.isactive,
    iol.created,
    iol.createdby,
    iol.updated,
    iol.updatedby,
    'en_US'::text AS ad_language,
    iol.m_inout_id,
    iol.m_inoutline_id,
    iol.line,
    p.m_product_id,
    CASE
    WHEN ((iol.movementqty <> (0)::numeric) OR (iol.m_product_id IS NOT NULL)) THEN iol.movementqty
    ELSE NULL::numeric
    END AS movementqty,
    CASE
    WHEN ((iol.qtyentered <> (0)::numeric) OR (iol.m_product_id IS NOT NULL)) THEN iol.qtyentered
    ELSE NULL::numeric
    END AS qtyentered,
    CASE
    WHEN ((iol.movementqty <> (0)::numeric) OR (iol.m_product_id IS NOT NULL)) THEN uom.uomsymbol
    ELSE NULL::character varying
    END AS uomsymbol,
    ol.qtyordered,
    ol.qtydelivered,
    CASE
    WHEN ((iol.movementqty <> (0)::numeric) OR (iol.m_product_id IS NOT NULL)) THEN (ol.qtyordered - ol.qtydelivered)
    ELSE NULL::numeric
    END AS qtybackordered,
    COALESCE(((p.name)::text || (productattribute(iol.m_attributesetinstance_id))::text), (c.name)::text, (iol.description)::text) AS name,
    CASE
    WHEN (COALESCE(c.name, p.name) IS NOT NULL) THEN iol.description
    ELSE NULL::character varying
    END AS description,
    p.documentnote,
    p.upc,
    p.sku,
    p.value AS productvalue,
    iol.m_locator_id,
    l.m_warehouse_id,
    l.x,
    l.y,
    l.z,
    iol.m_attributesetinstance_id,
    asi.m_attributeset_id,
    asi.serno,
    asi.lot,
    asi.m_lot_id,
    asi.guaranteedate,
    p.description AS productdescription,
    p.imageurl,
    iol.c_campaign_id,
    iol.c_project_id,
    iol.c_activity_id,
    iol.c_projectphase_id,
    iol.c_projecttask_id,
    ol.priceentered
  FROM ((((((m_inoutline iol
    JOIN c_uom uom ON ((iol.c_uom_id = uom.c_uom_id)))
    LEFT JOIN m_product p ON ((iol.m_product_id = p.m_product_id)))
    LEFT JOIN m_attributesetinstance asi ON ((iol.m_attributesetinstance_id = asi.m_attributesetinstance_id)))
    LEFT JOIN m_locator l ON ((iol.m_locator_id = l.m_locator_id)))
    LEFT JOIN c_orderline ol ON ((iol.c_orderline_id = ol.c_orderline_id)))
    LEFT JOIN c_charge c ON ((iol.c_charge_id = c.c_charge_id)))
    WHERE iol.isactive = 'Y'
  UNION
  SELECT iol.ad_client_id,
    iol.ad_org_id,
    iol.isactive,
    iol.created,
    iol.createdby,
    iol.updated,
    iol.updatedby,
    'en_US'::text AS ad_language,
    iol.m_inout_id,
    iol.m_inoutline_id,
    (iol.line + (bl.line / (100)::numeric)) AS line,
    p.m_product_id,
    CASE
    WHEN (bl.isqtypercentage = 'N'::bpchar) THEN (iol.movementqty * bl.qtybom)
    ELSE (iol.movementqty * (bl.qtybatch / (100)::numeric))
    END AS movementqty,
    CASE
    WHEN (bl.isqtypercentage = 'N'::bpchar) THEN (iol.qtyentered * bl.qtybom)
    ELSE (iol.qtyentered * (bl.qtybatch / (100)::numeric))
    END AS qtyentered,
    uom.uomsymbol,
    NULL::numeric AS qtyordered,
    NULL::numeric AS qtydelivered,
    NULL::numeric AS qtybackordered,
    p.name,
    b.description,
    p.documentnote,
    p.upc,
    p.sku,
    p.value AS productvalue,
    iol.m_locator_id,
    l.m_warehouse_id,
    l.x,
    l.y,
    l.z,
    iol.m_attributesetinstance_id,
    asi.m_attributeset_id,
    asi.serno,
    asi.lot,
    asi.m_lot_id,
    asi.guaranteedate,
    p.description AS productdescription,
    p.imageurl,
    iol.c_campaign_id,
    iol.c_project_id,
    iol.c_activity_id,
    iol.c_projectphase_id,
    iol.c_projecttask_id,
    ol.priceentered
  FROM (((((((pp_product_bom b
    JOIN m_inoutline iol ON ((b.m_product_id = iol.m_product_id)))
    JOIN m_product bp ON (((bp.m_product_id = iol.m_product_id) AND (bp.isbom = 'Y'::bpchar) AND (bp.isverified = 'Y'::bpchar) AND (bp.ispicklistprintdetails = 'Y'::bpchar))))
    JOIN pp_product_bomline bl ON ((bl.pp_product_bom_id = b.pp_product_bom_id)))
    JOIN m_product p ON ((bl.m_product_id = p.m_product_id)))
    JOIN c_uom uom ON ((p.c_uom_id = uom.c_uom_id)))
    LEFT JOIN m_attributesetinstance asi ON ((iol.m_attributesetinstance_id = asi.m_attributesetinstance_id)))
    LEFT JOIN m_locator l ON ((iol.m_locator_id = l.m_locator_id)))
    LEFT JOIN c_orderline ol ON ((iol.c_orderline_id = ol.c_orderline_id))
  WHERE iol.isactive = 'Y';


--
-- Name: m_inout_line_vt; Type: VIEW; Schema: adempiere; Owner: -
--

CREATE OR REPLACE VIEW m_inout_line_vt AS
  SELECT iol.ad_client_id,
    iol.ad_org_id,
    iol.isactive,
    iol.created,
    iol.createdby,
    iol.updated,
    iol.updatedby,
    uom.ad_language,
    iol.m_inout_id,
    iol.m_inoutline_id,
    iol.line,
    p.m_product_id,
    CASE
    WHEN ((iol.movementqty <> (0)::numeric) OR (iol.m_product_id IS NOT NULL)) THEN iol.movementqty
    ELSE NULL::numeric
    END AS movementqty,
    CASE
    WHEN ((iol.qtyentered <> (0)::numeric) OR (iol.m_product_id IS NOT NULL)) THEN iol.qtyentered
    ELSE NULL::numeric
    END AS qtyentered,
    CASE
    WHEN ((iol.movementqty <> (0)::numeric) OR (iol.m_product_id IS NOT NULL)) THEN uom.uomsymbol
    ELSE NULL::character varying
    END AS uomsymbol,
    ol.qtyordered,
    ol.qtydelivered,
    CASE
    WHEN ((iol.movementqty <> (0)::numeric) OR (iol.m_product_id IS NOT NULL)) THEN (ol.qtyordered - ol.qtydelivered)
    ELSE NULL::numeric
    END AS qtybackordered,
    COALESCE(((COALESCE(pt.name, p.name))::text || (productattribute(iol.m_attributesetinstance_id))::text), (c.name)::text, (iol.description)::text) AS name,
    CASE
    WHEN (COALESCE(pt.name, p.name, c.name) IS NOT NULL) THEN iol.description
    ELSE NULL::character varying
    END AS description,
    COALESCE(pt.documentnote, p.documentnote) AS documentnote,
    p.upc,
    p.sku,
    p.value AS productvalue,
    iol.m_locator_id,
    l.m_warehouse_id,
    l.x,
    l.y,
    l.z,
    iol.m_attributesetinstance_id,
    asi.m_attributeset_id,
    asi.serno,
    asi.lot,
    asi.m_lot_id,
    asi.guaranteedate,
    pt.description AS productdescription,
    p.imageurl,
    iol.c_campaign_id,
    iol.c_project_id,
    iol.c_activity_id,
    iol.c_projectphase_id,
    iol.c_projecttask_id,
    ol.priceentered
  FROM (((((((m_inoutline iol
    JOIN c_uom_trl uom ON ((iol.c_uom_id = uom.c_uom_id)))
    LEFT JOIN m_product p ON ((iol.m_product_id = p.m_product_id)))
    LEFT JOIN m_product_trl pt ON (((iol.m_product_id = pt.m_product_id) AND ((uom.ad_language)::text = (pt.ad_language)::text))))
    LEFT JOIN m_attributesetinstance asi ON ((iol.m_attributesetinstance_id = asi.m_attributesetinstance_id)))
    LEFT JOIN m_locator l ON ((iol.m_locator_id = l.m_locator_id)))
    LEFT JOIN c_orderline ol ON ((iol.c_orderline_id = ol.c_orderline_id)))
    LEFT JOIN c_charge_trl c ON ((iol.c_charge_id = c.c_charge_id)))
  WHERE iol.isactive = 'Y'
  UNION
  SELECT iol.ad_client_id,
    iol.ad_org_id,
    iol.isactive,
    iol.created,
    iol.createdby,
    iol.updated,
    iol.updatedby,
    uom.ad_language,
    iol.m_inout_id,
    iol.m_inoutline_id,
    (iol.line + (bl.line / (100)::numeric)) AS line,
    p.m_product_id,
    CASE
    WHEN (bl.isqtypercentage = 'N'::bpchar) THEN (iol.movementqty * bl.qtybom)
    ELSE (iol.movementqty * (bl.qtybatch / (100)::numeric))
    END AS movementqty,
    CASE
    WHEN (bl.isqtypercentage = 'N'::bpchar) THEN (iol.qtyentered * bl.qtybom)
    ELSE (iol.qtyentered * (bl.qtybatch / (100)::numeric))
    END AS qtyentered,
    uom.uomsymbol,
    NULL::numeric AS qtyordered,
    NULL::numeric AS qtydelivered,
    NULL::numeric AS qtybackordered,
    COALESCE(pt.name, p.name) AS name,
    b.description,
    COALESCE(pt.documentnote, p.documentnote) AS documentnote,
    p.upc,
    p.sku,
    p.value AS productvalue,
    iol.m_locator_id,
    l.m_warehouse_id,
    l.x,
    l.y,
    l.z,
    iol.m_attributesetinstance_id,
    asi.m_attributeset_id,
    asi.serno,
    asi.lot,
    asi.m_lot_id,
    asi.guaranteedate,
    pt.description AS productdescription,
    p.imageurl,
    iol.c_campaign_id,
    iol.c_project_id,
    iol.c_activity_id,
    iol.c_projectphase_id,
    iol.c_projecttask_id,
    ol.priceentered
  FROM ((((((((pp_product_bom b
    JOIN m_inoutline iol ON ((b.m_product_id = iol.m_product_id)))
    JOIN m_product bp ON (((bp.m_product_id = iol.m_product_id) AND (bp.isbom = 'Y'::bpchar) AND (bp.isverified = 'Y'::bpchar) AND (bp.ispicklistprintdetails = 'Y'::bpchar))))
    JOIN pp_product_bomline bl ON ((bl.pp_product_bom_id = b.pp_product_bom_id)))
    JOIN m_product p ON ((bl.m_product_id = p.m_product_id)))
    JOIN c_uom_trl uom ON ((p.c_uom_id = uom.c_uom_id)))
    JOIN m_product_trl pt ON (((bl.m_product_id = pt.m_product_id) AND ((uom.ad_language)::text = (pt.ad_language)::text))))
    LEFT JOIN m_attributesetinstance asi ON ((iol.m_attributesetinstance_id = asi.m_attributesetinstance_id)))
    LEFT JOIN m_locator l ON ((iol.m_locator_id = l.m_locator_id)))
    LEFT JOIN c_orderline ol ON ((iol.c_orderline_id = ol.c_orderline_id))
  WHERE iol.isactive = 'Y';

ALTER TABLE m_inout ADD COLUMN shipment_reason char;
ALTER TABLE m_inout ADD COLUMN freightassignmentrule char;
ALTER TABLE m_inout ADD COLUMN numberofitems numeric;
ALTER TABLE c_bpartner ADD COLUMN fiscalid varchar(20);

drop view m_inout_header_v;

CREATE OR REPLACE VIEW m_inout_header_v AS
  SELECT io.ad_client_id,
    io.ad_org_id,
    io.isactive,
    io.created,
    io.createdby,
    io.updated,
    io.updatedby,
    'en_US'::character varying AS ad_language,
    io.m_inout_id,
    io.issotrx,
    io.documentno,
    io.docstatus,
    io.c_doctype_id,
    io.c_bpartner_id,
    bp.value AS bpvalue,
    bp.taxid AS bptaxid,
    bp.fiscalid AS bpfiscalid,
    bp.naics,
    bp.duns,
    oi.c_location_id AS org_location_id,
    oi.taxid,
    io.m_warehouse_id,
    wh.c_location_id AS warehouse_location_id,
    dt.printname AS documenttype,
    dt.documentnote AS documenttypenote,
    io.c_order_id,
    io.movementdate,
    io.movementtype,
    bpg.greeting AS bpgreeting,
    bp.name,
    bp.name2,
    bpcg.greeting AS bpcontactgreeting,
    bpc.title,
    bpc.phone,
    NULLIF((bpc.name)::text, (bp.name)::text) AS contactname,
    bpl.c_location_id,
    ((l.postal)::text || (l.postal_add)::text) AS postal,
    bp.referenceno,
    io.description,
    io.poreference,
    io.dateordered,
    io.volume,
    io.weight,
    io.m_shipper_id,
    io.deliveryrule,
    io.deliveryviarule,
    io.priorityrule,
    COALESCE(oi.logo_id, ci.logo_id) AS logo_id,
    shipment_reason,
    freightassignmentrule,
    numberofitems,
    io.shipdate
  FROM ((((((((((m_inout io
    JOIN c_doctype dt ON ((io.c_doctype_id = dt.c_doctype_id)))
    JOIN c_bpartner bp ON ((io.c_bpartner_id = bp.c_bpartner_id)))
    LEFT JOIN c_greeting bpg ON ((bp.c_greeting_id = bpg.c_greeting_id)))
    JOIN c_bpartner_location bpl ON ((io.c_bpartner_location_id = bpl.c_bpartner_location_id)))
    JOIN c_location l ON ((bpl.c_location_id = l.c_location_id)))
    LEFT JOIN ad_user bpc ON ((io.ad_user_id = bpc.ad_user_id)))
    LEFT JOIN c_greeting bpcg ON ((bpc.c_greeting_id = bpcg.c_greeting_id)))
    JOIN ad_orginfo oi ON ((io.ad_org_id = oi.ad_org_id)))
    JOIN ad_clientinfo ci ON ((io.ad_client_id = ci.ad_client_id)))
    JOIN m_warehouse wh ON ((io.m_warehouse_id = wh.m_warehouse_id)));


--
-- Name: m_inout_header_vt; Type: VIEW; Schema: adempiere; Owner: -
--

drop view m_inout_header_vt;

CREATE  OR REPLACE VIEW m_inout_header_vt AS
  SELECT io.ad_client_id,
    io.ad_org_id,
    io.isactive,
    io.created,
    io.createdby,
    io.updated,
    io.updatedby,
    dt.ad_language,
    io.m_inout_id,
    io.issotrx,
    io.documentno,
    io.docstatus,
    io.c_doctype_id,
    io.c_bpartner_id,
    bp.value AS bpvalue,
    bp.taxid AS bptaxid,
    bp.fiscalid AS bpfiscalid,
    bp.naics,
    bp.duns,
    oi.c_location_id AS org_location_id,
    oi.taxid,
    io.m_warehouse_id,
    wh.c_location_id AS warehouse_location_id,
    dt.printname AS documenttype,
    dt.documentnote AS documenttypenote,
    io.c_order_id,
    bpc.phone,
    io.movementdate,
    io.movementtype,
    bpg.greeting AS bpgreeting,
    bp.name,
    bp.name2,
    bpcg.greeting AS bpcontactgreeting,
    bpc.title,
    NULLIF((bpc.name)::text, (bp.name)::text) AS contactname,
    bpl.c_location_id,
    ((l.postal)::text || (l.postal_add)::text) AS postal,
    bp.referenceno,
    io.description,
    io.poreference,
    io.dateordered,
    io.volume,
    io.weight,
    io.m_shipper_id,
    io.deliveryrule,
    io.deliveryviarule,
    io.priorityrule,
    COALESCE(oi.logo_id, ci.logo_id) AS logo_id,
    shipment_reason,
    freightassignmentrule,
    numberofitems,
    io.shipdate
  FROM ((((((((((m_inout io
    JOIN c_doctype_trl dt ON ((io.c_doctype_id = dt.c_doctype_id)))
    JOIN c_bpartner bp ON ((io.c_bpartner_id = bp.c_bpartner_id)))
    LEFT JOIN c_greeting_trl bpg ON (((bp.c_greeting_id = bpg.c_greeting_id) AND ((dt.ad_language)::text = (bpg.ad_language)::text))))
    JOIN c_bpartner_location bpl ON ((io.c_bpartner_location_id = bpl.c_bpartner_location_id)))
    JOIN c_location l ON ((bpl.c_location_id = l.c_location_id)))
    LEFT JOIN ad_user bpc ON ((io.ad_user_id = bpc.ad_user_id)))
    LEFT JOIN c_greeting_trl bpcg ON (((bpc.c_greeting_id = bpcg.c_greeting_id) AND ((dt.ad_language)::text = (bpcg.ad_language)::text))))
    JOIN ad_orginfo oi ON ((io.ad_org_id = oi.ad_org_id)))
    JOIN ad_clientinfo ci ON ((io.ad_client_id = ci.ad_client_id)))
    JOIN m_warehouse wh ON ((io.m_warehouse_id = wh.m_warehouse_id)));


CREATE OR REPLACE VIEW m_inout_candidate_v AS
  SELECT o.ad_client_id,
    o.ad_org_id,
    o.c_bpartner_id,
    o.c_order_id,
    o.documentno,
    o.dateordered,
    o.c_doctype_id,
    o.poreference,
    o.description,
    o.salesrep_id,
    l.m_warehouse_id,
    sum(((l.qtyordered - l.qtydelivered) * l.priceactual)) AS totallines
  FROM (c_order o
    JOIN c_orderline l ON ((o.c_order_id = l.c_order_id)))
  WHERE ((o.docstatus = 'CO'::bpchar) AND (o.isdelivered = 'N'::bpchar) AND (o.c_doctype_id IN ( SELECT c_doctype.c_doctype_id
                                                                                                 FROM c_doctype
                                                                                                 WHERE ((c_doctype.docbasetype = 'SOO'::bpchar) AND (c_doctype.docsubtypeso <> ALL (ARRAY['ON'::bpchar, 'WR'::bpchar]))))) AND (o.deliveryrule <> 'M'::bpchar) AND ((l.m_product_id IS NULL) OR (EXISTS ( SELECT p.m_product_id,
                                                                                                                                                                                                                                                                                                                          p.ad_client_id,
                                                                                                                                                                                                                                                                                                                          p.ad_org_id,
                                                                                                                                                                                                                                                                                                                          p.isactive,
                                                                                                                                                                                                                                                                                                                          p.created,
                                                                                                                                                                                                                                                                                                                          p.createdby,
                                                                                                                                                                                                                                                                                                                          p.updated,
                                                                                                                                                                                                                                                                                                                          p.updatedby,
                                                                                                                                                                                                                                                                                                                          p.value,
                                                                                                                                                                                                                                                                                                                          p.name,
                                                                                                                                                                                                                                                                                                                          p.description,
                                                                                                                                                                                                                                                                                                                          p.documentnote,
                                                                                                                                                                                                                                                                                                                          p.help,
                                                                                                                                                                                                                                                                                                                          p.upc,
                                                                                                                                                                                                                                                                                                                          p.sku,
                                                                                                                                                                                                                                                                                                                          p.c_uom_id,
                                                                                                                                                                                                                                                                                                                          p.salesrep_id,
                                                                                                                                                                                                                                                                                                                          p.issummary,
                                                                                                                                                                                                                                                                                                                          p.isstocked,
                                                                                                                                                                                                                                                                                                                          p.ispurchased,
                                                                                                                                                                                                                                                                                                                          p.issold,
                                                                                                                                                                                                                                                                                                                          p.isbom,
                                                                                                                                                                                                                                                                                                                          p.isinvoiceprintdetails,
                                                                                                                                                                                                                                                                                                                          p.ispicklistprintdetails,
                                                                                                                                                                                                                                                                                                                          p.isverified,
                                                                                                                                                                                                                                                                                                                          p.c_revenuerecognition_id,
                                                                                                                                                                                                                                                                                                                          p.m_product_category_id,
                                                                                                                                                                                                                                                                                                                          p.classification,
                                                                                                                                                                                                                                                                                                                          p.volume,
                                                                                                                                                                                                                                                                                                                          p.weight,
                                                                                                                                                                                                                                                                                                                          p.shelfwidth,
                                                                                                                                                                                                                                                                                                                          p.shelfheight,
                                                                                                                                                                                                                                                                                                                          p.shelfdepth,
                                                                                                                                                                                                                                                                                                                          p.unitsperpallet,
                                                                                                                                                                                                                                                                                                                          p.c_taxcategory_id,
                                                                                                                                                                                                                                                                                                                          p.s_resource_id,
                                                                                                                                                                                                                                                                                                                          p.discontinued,
                                                                                                                                                                                                                                                                                                                          p.discontinuedby,
                                                                                                                                                                                                                                                                                                                          p.processing,
                                                                                                                                                                                                                                                                                                                          p.s_expensetype_id,
                                                                                                                                                                                                                                                                                                                          p.producttype,
                                                                                                                                                                                                                                                                                                                          p.imageurl,
                                                                                                                                                                                                                                                                                                                          p.descriptionurl,
                                                                                                                                                                                                                                                                                                                          p.guaranteedays,
                                                                                                                                                                                                                                                                                                                          p.r_mailtext_id,
                                                                                                                                                                                                                                                                                                                          p.versionno,
                                                                                                                                                                                                                                                                                                                          p.m_attributeset_id,
                                                                                                                                                                                                                                                                                                                          p.m_attributesetinstance_id,
                                                                                                                                                                                                                                                                                                                          p.downloadurl,
                                                                                                                                                                                                                                                                                                                          p.m_freightcategory_id,
                                                                                                                                                                                                                                                                                                                          p.m_locator_id,
                                                                                                                                                                                                                                                                                                                          p.guaranteedaysmin,
                                                                                                                                                                                                                                                                                                                          p.iswebstorefeatured,
                                                                                                                                                                                                                                                                                                                          p.isselfservice,
                                                                                                                                                                                                                                                                                                                          p.c_subscriptiontype_id,
                                                                                                                                                                                                                                                                                                                          p.isdropship,
                                                                                                                                                                                                                                                                                                                          p.isexcludeautodelivery,
                                                                                                                                                                                                                                                                                                                          p.group1,
                                                                                                                                                                                                                                                                                                                          p.group2,
                                                                                                                                                                                                                                                                                                                          p.istoformule,
                                                                                                                                                                                                                                                                                                                          p.lowlevel,
                                                                                                                                                                                                                                                                                                                          p.unitsperpack,
                                                                                                                                                                                                                                                                                                                          p.discontinuedat,
                                                                                                                                                                                                                                                                                                                          p.copyfrom
                                                                                                                                                                                                                                                                                                                        FROM m_product p
                                                                                                                                                                                                                                                                                                                        WHERE ((l.m_product_id = p.m_product_id) AND (p.isexcludeautodelivery = 'N'::bpchar))))) AND (l.qtyordered <> l.qtydelivered) AND (o.isdropship = 'N'::bpchar) AND ((l.m_product_id IS NOT NULL) OR (l.c_charge_id IS NOT NULL)) AND (NOT (EXISTS ( SELECT iol.m_inoutline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.ad_client_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.ad_org_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.isactive,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.created,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.createdby,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.updated,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.updatedby,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.line,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.description,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.m_inout_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.c_orderline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.m_locator_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.m_product_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.c_uom_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.movementqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.isinvoiced,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.m_attributesetinstance_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.isdescription,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.confirmedqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.pickedqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.scrappedqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.targetqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.ref_inoutline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.processed,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.qtyentered,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.c_charge_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.c_project_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.c_projectphase_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.c_projecttask_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.c_campaign_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.c_activity_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.user1_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.user2_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.ad_orgtrx_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.m_rmaline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              iol.reversalline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.m_inout_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.ad_client_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.ad_org_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.isactive,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.created,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.createdby,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.updated,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.updatedby,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.issotrx,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.documentno,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.docaction,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.docstatus,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.posted,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.processing,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.processed,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_doctype_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.description,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_order_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.dateordered,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.isprinted,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.movementtype,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.movementdate,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.dateacct,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_bpartner_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_bpartner_location_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.m_warehouse_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.poreference,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.deliveryrule,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.freightcostrule,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.freightamt,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.deliveryviarule,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.m_shipper_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_charge_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.chargeamt,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.priorityrule,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.dateprinted,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_invoice_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.createfrom,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.generateto,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.sendemail,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.ad_user_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.salesrep_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.nopackages,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.pickdate,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.shipdate,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.trackingno,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.ad_orgtrx_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_project_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_campaign_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.c_activity_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.user1_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.user2_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.datereceived,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.isintransit,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.ref_inout_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.createconfirm,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.createpackage,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.isapproved,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.isindispute,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.volume,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.weight,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.m_rma_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.reversal_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.isdropship,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.dropship_bpartner_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.dropship_location_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.dropship_user_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              io.processedon
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            FROM (m_inoutline iol
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              JOIN m_inout io ON ((iol.m_inout_id = io.m_inout_id)))
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            WHERE ((iol.c_orderline_id = l.c_orderline_id) AND (io.docstatus = ANY (ARRAY['IP'::bpchar, 'WC'::bpchar])))))))
  GROUP BY o.ad_client_id, o.ad_org_id, o.c_bpartner_id, o.c_order_id, o.documentno, o.dateordered, o.c_doctype_id, o.poreference, o.description, o.salesrep_id, l.m_warehouse_id;CREATE OR REPLACE VIEW m_inout_candidate_v AS
  SELECT o.ad_client_id,
    o.ad_org_id,
    o.c_bpartner_id,
    o.c_order_id,
    o.documentno,
    o.dateordered,
    o.c_doctype_id,
    o.poreference,
    o.description,
    o.salesrep_id,
    l.m_warehouse_id,
    sum(((l.qtyordered - l.qtydelivered) * l.priceactual)) AS totallines
  FROM (c_order o
    JOIN c_orderline l ON ((o.c_order_id = l.c_order_id)))
  WHERE ((o.docstatus = 'CO'::bpchar) AND (o.isdelivered = 'N'::bpchar) AND (o.c_doctype_id IN ( SELECT c_doctype.c_doctype_id
                                                                                                 FROM c_doctype
                                                                                                 WHERE ((c_doctype.docbasetype = 'SOO'::bpchar) AND (c_doctype.docsubtypeso <> ALL (ARRAY['ON'::bpchar, 'WR'::bpchar]))))) AND (o.deliveryrule <> 'M'::bpchar) AND ((l.m_product_id IS NULL) OR (EXISTS ( SELECT p.m_product_id,
                                                                                                                                                                                                                                                                                                            p.ad_client_id,
                                                                                                                                                                                                                                                                                                            p.ad_org_id,
                                                                                                                                                                                                                                                                                                            p.isactive,
                                                                                                                                                                                                                                                                                                            p.created,
                                                                                                                                                                                                                                                                                                            p.createdby,
                                                                                                                                                                                                                                                                                                            p.updated,
                                                                                                                                                                                                                                                                                                            p.updatedby,
                                                                                                                                                                                                                                                                                                            p.value,
                                                                                                                                                                                                                                                                                                            p.name,
                                                                                                                                                                                                                                                                                                            p.description,
                                                                                                                                                                                                                                                                                                            p.documentnote,
                                                                                                                                                                                                                                                                                                            p.help,
                                                                                                                                                                                                                                                                                                            p.upc,
                                                                                                                                                                                                                                                                                                            p.sku,
                                                                                                                                                                                                                                                                                                            p.c_uom_id,
                                                                                                                                                                                                                                                                                                            p.salesrep_id,
                                                                                                                                                                                                                                                                                                            p.issummary,
                                                                                                                                                                                                                                                                                                            p.isstocked,
                                                                                                                                                                                                                                                                                                            p.ispurchased,
                                                                                                                                                                                                                                                                                                            p.issold,
                                                                                                                                                                                                                                                                                                            p.isbom,
                                                                                                                                                                                                                                                                                                            p.isinvoiceprintdetails,
                                                                                                                                                                                                                                                                                                            p.ispicklistprintdetails,
                                                                                                                                                                                                                                                                                                            p.isverified,
                                                                                                                                                                                                                                                                                                            p.c_revenuerecognition_id,
                                                                                                                                                                                                                                                                                                            p.m_product_category_id,
                                                                                                                                                                                                                                                                                                            p.classification,
                                                                                                                                                                                                                                                                                                            p.volume,
                                                                                                                                                                                                                                                                                                            p.weight,
                                                                                                                                                                                                                                                                                                            p.shelfwidth,
                                                                                                                                                                                                                                                                                                            p.shelfheight,
                                                                                                                                                                                                                                                                                                            p.shelfdepth,
                                                                                                                                                                                                                                                                                                            p.unitsperpallet,
                                                                                                                                                                                                                                                                                                            p.c_taxcategory_id,
                                                                                                                                                                                                                                                                                                            p.s_resource_id,
                                                                                                                                                                                                                                                                                                            p.discontinued,
                                                                                                                                                                                                                                                                                                            p.discontinuedby,
                                                                                                                                                                                                                                                                                                            p.processing,
                                                                                                                                                                                                                                                                                                            p.s_expensetype_id,
                                                                                                                                                                                                                                                                                                            p.producttype,
                                                                                                                                                                                                                                                                                                            p.imageurl,
                                                                                                                                                                                                                                                                                                            p.descriptionurl,
                                                                                                                                                                                                                                                                                                            p.guaranteedays,
                                                                                                                                                                                                                                                                                                            p.r_mailtext_id,
                                                                                                                                                                                                                                                                                                            p.versionno,
                                                                                                                                                                                                                                                                                                            p.m_attributeset_id,
                                                                                                                                                                                                                                                                                                            p.m_attributesetinstance_id,
                                                                                                                                                                                                                                                                                                            p.downloadurl,
                                                                                                                                                                                                                                                                                                            p.m_freightcategory_id,
                                                                                                                                                                                                                                                                                                            p.m_locator_id,
                                                                                                                                                                                                                                                                                                            p.guaranteedaysmin,
                                                                                                                                                                                                                                                                                                            p.iswebstorefeatured,
                                                                                                                                                                                                                                                                                                            p.isselfservice,
                                                                                                                                                                                                                                                                                                            p.c_subscriptiontype_id,
                                                                                                                                                                                                                                                                                                            p.isdropship,
                                                                                                                                                                                                                                                                                                            p.isexcludeautodelivery,
                                                                                                                                                                                                                                                                                                            p.group1,
                                                                                                                                                                                                                                                                                                            p.group2,
                                                                                                                                                                                                                                                                                                            p.istoformule,
                                                                                                                                                                                                                                                                                                            p.lowlevel,
                                                                                                                                                                                                                                                                                                            p.unitsperpack,
                                                                                                                                                                                                                                                                                                            p.discontinuedat,
                                                                                                                                                                                                                                                                                                            p.copyfrom
                                                                                                                                                                                                                                                                                                          FROM m_product p
                                                                                                                                                                                                                                                                                                          WHERE ((l.m_product_id = p.m_product_id) AND (p.isexcludeautodelivery = 'N'::bpchar))))) AND (l.qtyordered <> l.qtydelivered) AND (o.isdropship = 'N'::bpchar) AND ((l.m_product_id IS NOT NULL) OR (l.c_charge_id IS NOT NULL)) AND (NOT (EXISTS ( SELECT iol.m_inoutline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.ad_client_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.ad_org_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.isactive,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.created,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.createdby,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.updated,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.updatedby,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.line,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.description,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.m_inout_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.c_orderline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.m_locator_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.m_product_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.c_uom_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.movementqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.isinvoiced,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.m_attributesetinstance_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.isdescription,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.confirmedqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.pickedqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.scrappedqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.targetqty,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.ref_inoutline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.processed,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.qtyentered,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.c_charge_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.c_project_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.c_projectphase_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.c_projecttask_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.c_campaign_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.c_activity_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.user1_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.user2_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.ad_orgtrx_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.m_rmaline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                iol.reversalline_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.m_inout_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.ad_client_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.ad_org_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.isactive,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.created,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.createdby,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.updated,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.updatedby,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.issotrx,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.documentno,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.docaction,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.docstatus,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.posted,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.processing,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.processed,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_doctype_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.description,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_order_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.dateordered,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.isprinted,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.movementtype,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.movementdate,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.dateacct,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_bpartner_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_bpartner_location_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.m_warehouse_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.poreference,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.deliveryrule,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.freightcostrule,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.freightamt,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.deliveryviarule,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.m_shipper_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_charge_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.chargeamt,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.priorityrule,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.dateprinted,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_invoice_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.createfrom,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.generateto,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.sendemail,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.ad_user_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.salesrep_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.nopackages,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.pickdate,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.shipdate,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.trackingno,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.ad_orgtrx_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_project_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_campaign_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.c_activity_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.user1_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.user2_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.datereceived,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.isintransit,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.ref_inout_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.createconfirm,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.createpackage,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.isapproved,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.isindispute,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.volume,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.weight,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.m_rma_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.reversal_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.isdropship,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.dropship_bpartner_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.dropship_location_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.dropship_user_id,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                io.processedon
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              FROM (m_inoutline iol
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                JOIN m_inout io ON ((iol.m_inout_id = io.m_inout_id)))
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              WHERE ((iol.c_orderline_id = l.c_orderline_id) AND (io.docstatus = ANY (ARRAY['IP'::bpchar, 'WC'::bpchar])))))))
  GROUP BY o.ad_client_id, o.ad_org_id, o.c_bpartner_id, o.c_order_id, o.documentno, o.dateordered, o.c_doctype_id, o.poreference, o.description, o.salesrep_id, l.m_warehouse_id;

drop view c_invoice_header_v;
CREATE OR REPLACE VIEW c_invoice_header_v AS
  SELECT i.ad_client_id,
    i.ad_org_id,
    i.isactive,
    i.created,
    i.createdby,
    i.updated,
    i.updatedby,
    'en_US'::character varying AS ad_language,
    i.c_invoice_id,
    i.issotrx,
    i.documentno,
    i.docstatus,
    i.c_doctype_id,
    i.c_bpartner_id,
    bp.value AS bpvalue,
    bp.taxid AS bptaxid,
    bp.fiscalid AS bpfiscalid,
    bp.naics,
    bp.duns,
    oi.c_location_id AS org_location_id,
    oi.taxid,
    dt.printname AS documenttype,
    dt.documentnote AS documenttypenote,
    i.c_order_id,
    i.salesrep_id,
    COALESCE(ubp.name, u.name) AS salesrep_name,
    i.dateinvoiced,
    bpg.greeting AS bpgreeting,
    bp.name,
    bp.name2,
    bpcg.greeting AS bpcontactgreeting,
    bpc.title,
    bpc.phone,
    NULLIF((bpc.name)::text, (bp.name)::text) AS contactname,
    bpl.c_location_id,
    bp.referenceno,
    ((l.postal)::text || (l.postal_add)::text) AS postal,
    i.description,
    i.poreference,
    i.dateordered,
    i.c_currency_id,
    pt.name AS paymentterm,
    pt.documentnote AS paymenttermnote,
    i.c_charge_id,
    i.chargeamt,
    i.totallines,
    i.grandtotal,
    i.grandtotal AS amtinwords,
    i.m_pricelist_id,
    i.istaxincluded,
    i.c_campaign_id,
    i.c_project_id,
    i.c_activity_id,
    i.ispaid,
    COALESCE(oi.logo_id, ci.logo_id) AS logo_id
  FROM ((((((((((((c_invoice i
    JOIN c_doctype dt ON ((i.c_doctype_id = dt.c_doctype_id)))
    JOIN c_paymentterm pt ON ((i.c_paymentterm_id = pt.c_paymentterm_id)))
    JOIN c_bpartner bp ON ((i.c_bpartner_id = bp.c_bpartner_id)))
    LEFT JOIN c_greeting bpg ON ((bp.c_greeting_id = bpg.c_greeting_id)))
    JOIN c_bpartner_location bpl ON ((i.c_bpartner_location_id = bpl.c_bpartner_location_id)))
    JOIN c_location l ON ((bpl.c_location_id = l.c_location_id)))
    LEFT JOIN ad_user bpc ON ((i.ad_user_id = bpc.ad_user_id)))
    LEFT JOIN c_greeting bpcg ON ((bpc.c_greeting_id = bpcg.c_greeting_id)))
    JOIN ad_orginfo oi ON ((i.ad_org_id = oi.ad_org_id)))
    JOIN ad_clientinfo ci ON ((i.ad_client_id = ci.ad_client_id)))
    LEFT JOIN ad_user u ON ((i.salesrep_id = u.ad_user_id)))
    LEFT JOIN c_bpartner ubp ON ((u.c_bpartner_id = ubp.c_bpartner_id)));


--
-- Name: c_invoice_header_vt; Type: VIEW; Schema: adempiere; Owner: -
--
drop view c_invoice_header_vt;

CREATE OR REPLACE VIEW c_invoice_header_vt AS
  SELECT i.ad_client_id,
    i.ad_org_id,
    i.isactive,
    i.created,
    i.createdby,
    i.updated,
    i.updatedby,
    dt.ad_language,
    i.c_invoice_id,
    i.issotrx,
    i.documentno,
    i.docstatus,
    i.c_doctype_id,
    i.c_bpartner_id,
    bp.value AS bpvalue,
    bp.taxid AS bptaxid,
    bp.fiscalid AS bpfiscalid,
    bp.naics,
    bp.duns,
    oi.c_location_id AS org_location_id,
    oi.taxid,
    dt.printname AS documenttype,
    dt.documentnote AS documenttypenote,
    i.c_order_id,
    i.salesrep_id,
    COALESCE(ubp.name, u.name) AS salesrep_name,
    i.dateinvoiced,
    bpg.greeting AS bpgreeting,
    bp.name,
    bp.name2,
    bpcg.greeting AS bpcontactgreeting,
    bpc.title,
    bpc.phone,
    NULLIF((bpc.name)::text, (bp.name)::text) AS contactname,
    bpl.c_location_id,
    bp.referenceno,
    ((l.postal)::text || (l.postal_add)::text) AS postal,
    i.description,
    i.poreference,
    i.dateordered,
    i.c_currency_id,
    pt.name AS paymentterm,
    pt.documentnote AS paymenttermnote,
    i.c_charge_id,
    i.chargeamt,
    i.totallines,
    i.grandtotal,
    i.grandtotal AS amtinwords,
    i.m_pricelist_id,
    i.istaxincluded,
    i.c_campaign_id,
    i.c_project_id,
    i.c_activity_id,
    i.ispaid,
    COALESCE(oi.logo_id, ci.logo_id) AS logo_id
  FROM ((((((((((((c_invoice i
    JOIN c_doctype_trl dt ON ((i.c_doctype_id = dt.c_doctype_id)))
    JOIN c_paymentterm_trl pt ON (((i.c_paymentterm_id = pt.c_paymentterm_id) AND ((dt.ad_language)::text = (pt.ad_language)::text))))
    JOIN c_bpartner bp ON ((i.c_bpartner_id = bp.c_bpartner_id)))
    LEFT JOIN c_greeting_trl bpg ON (((bp.c_greeting_id = bpg.c_greeting_id) AND ((dt.ad_language)::text = (bpg.ad_language)::text))))
    JOIN c_bpartner_location bpl ON ((i.c_bpartner_location_id = bpl.c_bpartner_location_id)))
    JOIN c_location l ON ((bpl.c_location_id = l.c_location_id)))
    LEFT JOIN ad_user bpc ON ((i.ad_user_id = bpc.ad_user_id)))
    LEFT JOIN c_greeting_trl bpcg ON (((bpc.c_greeting_id = bpcg.c_greeting_id) AND ((dt.ad_language)::text = (bpcg.ad_language)::text))))
    JOIN ad_orginfo oi ON ((i.ad_org_id = oi.ad_org_id)))
    JOIN ad_clientinfo ci ON ((i.ad_client_id = ci.ad_client_id)))
    LEFT JOIN ad_user u ON ((i.salesrep_id = u.ad_user_id)))
    LEFT JOIN c_bpartner ubp ON ((u.c_bpartner_id = ubp.c_bpartner_id)));

update c_doctype set C_DocTypeShipment_ID = 1000011 where c_doctype_id = 1000026;

drop index c_invoice_documentno_target;
drop index c_invoice_documentno;