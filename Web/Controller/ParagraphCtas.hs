module Web.Controller.ParagraphCtas where

import Web.Controller.Prelude
import Web.View.ParagraphCtas.Index
import Web.View.ParagraphCtas.New
import Web.View.ParagraphCtas.Edit
import Web.View.ParagraphCtas.Show

instance Controller ParagraphCtasController where
    action ParagraphCtaAction = do
        paragraphCtas <- query @ParagraphCta |> fetch
        render IndexView { .. }

    action NewParagraphCtaAction { landingPageId } = do
        -- Default weight should be the total of existing paragraphs on the landing page plus one.
        -- So we need to fetch the landing page with the paragraphs, and then count them.
        landingPage <- fetchLandingPageWithParagraphs landingPageId
        let weight = landingPage.paragraphCtas |> length |> (+) 1


        let paragraphCta = newRecord
                |> set #landingPageId landingPageId
                |> set #weight weight


        render NewView { .. }

    action ShowParagraphCtaAction { paragraphCtaId } = do
        paragraphCta <- fetch paragraphCtaId
        render ShowView { .. }

    action EditParagraphCtaAction { paragraphCtaId } = do
        paragraphCta <- fetch paragraphCtaId
        render EditView { .. }

    action UpdateParagraphCtaAction { paragraphCtaId } = do
        paragraphCta <- fetch paragraphCtaId
        paragraphCta
            |> buildParagraphCta
            |> ifValid \case
                Left paragraphCta -> render EditView { .. }
                Right paragraphCta -> do
                    paragraphCta <- paragraphCta |> updateRecord
                    setSuccessMessage "ParagraphCta updated"
                    redirectTo EditLandingPageAction { landingPageId = paragraphCta.landingPageId }

    action CreateParagraphCtaAction = do
        let paragraphCta = newRecord @ParagraphCta
        paragraphCta
            |> buildParagraphCta
            |> ifValid \case
                Left paragraphCta -> render NewView { .. }
                Right paragraphCta -> do
                    paragraphCta <- paragraphCta |> createRecord
                    setSuccessMessage "ParagraphCta created"
                    redirectTo EditLandingPageAction { landingPageId = paragraphCta.landingPageId }

    action DeleteParagraphCtaAction { paragraphCtaId } = do
        paragraphCta <- fetch paragraphCtaId
        deleteRecord paragraphCta
        setSuccessMessage "ParagraphCta deleted"
        redirectTo ParagraphCtaAction

buildParagraphCta paragraphCta = paragraphCta
    |> fill @'["title", "landingPageId", "weight"]
