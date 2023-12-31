module Application.Helper.Controller where

import IHP.ControllerPrelude
import Generated.Types
import Web.Types

-- Here you can add functions which are available in all your controllers

fetchLandingPageWithRecords :: (?modelContext :: ModelContext) => Id LandingPage -> IO LandingPageWithRecords
fetchLandingPageWithRecords landingPageId = do

    landingPage <- fetch landingPageId
    paragraphCtas <- query @ParagraphCta
        |> filterWhere (#landingPageId, landingPageId)
        |> fetch

    -- Landing pages referenced by ParagraphCta.refLandingPageId
    paragraphCtaRefLandingPages <- query @LandingPage
        |> filterWhereIn (#id, map (get #refLandingPageId) paragraphCtas)
        |> fetch

    paragraphQuotes <- query @ParagraphQuote
        |> filterWhere (#landingPageId, landingPageId)
        |> fetch

    return $ LandingPageWithRecords { .. }

getParagraphsCount :: (?modelContext::ModelContext) => Id LandingPage -> IO Int
getParagraphsCount landingPageId = do
    landingPageWithRecords <- fetchLandingPageWithRecords landingPageId

    pure $ length landingPageWithRecords.paragraphCtas
                    + length landingPageWithRecords.paragraphQuotes
                    + 1
